//
//  ViewController.swift
//  TheRightPrice
//
//  Created by Daniel Duan on 4/13/19.
//  Copyright © 2019 Daniel Duan. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

import Vision
import CoreML

import Firebase
import FirebaseFirestore

import CoreLocation

import SCLAlertView

class ARViewController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var mostAccuratePrediction = ""
    let serialQueue = DispatchQueue(label: "serialQueue")
    var requests = [VNRequest]()
    var location3D: ARHitTestResult?
    var textNodeParent = SCNNode()
    var price = ""
    
    var userLocation = CLLocation()
    
    
    var docRef: DocumentReference!
    var db: Firestore!
    
    var locationManager = CLLocationManager()
    
    var chosenObject = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        
        // SCENE
        sceneView.delegate = self
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.autoenablesDefaultLighting = true
        
        // CORE LOCATION
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        // PLACE NODE AT USER'S LOCATION
        
        
        // VISION
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading Core ML Model Failed.")
        }
        let request = VNCoreMLRequest(model: model, completionHandler: classificationCompletionHandler)
        request.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop
        requests = [request]
        coreMLLoop()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue: CLLocationCoordinate2D = manager.location!.coordinate
        if locations.last != nil {
            userLocation = locations.last!
        }
        else {
            print("ERROR MAP DUMBSHIT")
        }
        
    }
    

    func classificationCompletionHandler(request: VNRequest, error: Error?) {
        // Error present
        if error != nil {
            return
        }
        guard let results = request.results else {
            return
        }
        
        let predictions = results[0...1]
            .flatMap({ $0 as? VNClassificationObservation })
            .map({ "\($0.identifier) \(String(format:"- %.2f", $0.confidence))" })
            .joined(separator: "\n")
        
        // store the most accurate result
        DispatchQueue.main.async {
            var object = predictions.components(separatedBy: "-")[0]
            object = object.components(separatedBy: ",")[0]
            self.mostAccuratePrediction = object
        }
        
    }
    
    func coreMLLoop() {
        serialQueue.async {
            self.updateML()
            self.coreMLLoop()
        }
    }
    
    func updateML() {
        guard let pixelBuffer: CVPixelBuffer? = (sceneView.session.currentFrame?.capturedImage) else {
            return
        }
        
        
        let ciimage = CIImage(cvPixelBuffer: pixelBuffer!)
        let handler = VNImageRequestHandler(ciImage: ciimage, options: [:])
        do {
            try handler.perform(self.requests)
        } catch {
            print(error)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchLocation = touches.first?.location(in: sceneView) {
            
            let results = sceneView.hitTest(touchLocation, types: .featurePoint)
            
            if let hitResult = results.first {
                location3D = hitResult
                // delete all previous nodes before creating the new textNode
                sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
                    node.removeFromParentNode()
                }
                create3DText(at: location3D!, word: mostAccuratePrediction)
                // create the alert pop up
                createAlertView()
            }
            
        }
    }
    
    func createAlertView() {
        var alertViewResponder: SCLAlertViewResponder? = nil

        let appearance = SCLAlertView.SCLAppearance(
            kDefaultShadowOpacity: 0.2,
            showCloseButton: false,
            showCircularIcon: true,
            shouldAutoDismiss: false
        )
        
        let alertViewIcon = UIImage(named: "money_icon")
        
        // Initialize SCLAlertView using custom Appearance
        let alert = SCLAlertView(appearance: appearance)
        let txt = alert.addTextField("Object Name")
        let priceTxt = alert.addTextField("$0.00")
        alert.addButton("Update") {
            if txt.text != nil && txt.text != "" {
                self.mostAccuratePrediction = txt.text!
                self.chosenObject = txt.text!
                
                alertViewResponder!.setTitle(self.mostAccuratePrediction)
                alertViewResponder!.setSubTitle("Add the \(self.mostAccuratePrediction) to our map services!")
                // remove the current 3D text
                self.sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
                    node.removeFromParentNode()
                }
                // replace it with the updated most accurate result
                self.create3DText(at: self.location3D!, word: self.mostAccuratePrediction)
            }
            if priceTxt.text != nil && priceTxt.text != ""  {
                self.price = priceTxt.text!
            }
            self.saveToDatabase()
            // self.updateMap()
            
            alertViewResponder!.close()
        }
        alertViewResponder = alert.showInfo(mostAccuratePrediction, subTitle: "Add the \(self.mostAccuratePrediction) to our map services!", circleIconImage: alertViewIcon)
    }
    
    func saveToDatabase() {
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        print("\(latitude)")
        print("\(longitude)")
        docRef = db.collection("locations").addDocument(data: [
            "latitude": latitude,
            "longitude": longitude,
            "name" : mostAccuratePrediction,
            "price" : price
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(self.docRef!.documentID)")
            }
        }
    }
    
//    func updateMap() {
//        var secondTab = self.tabBarController?.viewControllers![1] as! MapViewController
//        
//        let allAnnotations = secondTab.mapView.annotations
//        secondTab.mapView.removeAnnotations(allAnnotations)
//        
//        
////        db.collection("locations").getDocuments() { (querySnapshot, err) in
////            if let err = err {
////                print("Error getting documents: \(err)")
////            } else {
////                for document in querySnapshot!.documents {
////                    let lat = document.get("latitude")!
////                    let long = document.get("longitude")!
////                    let name = document.get("name")! as! String
////                    let coord = CLLocationCoordinate2D(latitude: lat as! CLLocationDegrees, longitude: long as! CLLocationDegrees)
////                    let annotation = PlaceAnnotation(location: coord, title: name)
////
////                    DispatchQueue.main.async {
////                        secondTab.mapView.addAnnotation(annotation)
////                    }
////
//////                    let poiLocation = CLLocation(latitude: lat as! CLLocationDegrees, longitude: long as! CLLocationDegrees)
//////                    print("location: \(poiLocation)")
//////                    self.POIs.append(poiLocation)
////                }
////            }
////        }
//    }
    
    func create3DText(at hitResult: ARHitTestResult, word wordToCreate: String) {
        
        // CONSTRAINTS
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        
        // TEXT GEOMETRY
        let textGeometry = SCNText(string: wordToCreate, extrusionDepth: 0.01)
        var font = UIFont(name: "Futura", size: 0.15)
        font = font?.withTraits(traits: .traitBold)
        textGeometry.font = font
        textGeometry.alignmentMode = CATextLayerAlignmentMode.center.rawValue
        textGeometry.firstMaterial?.diffuse.contents = #colorLiteral(red: 0.2588235294, green: 0.5176470588, blue: 0.9529411765, alpha: 1)
        textGeometry.firstMaterial?.isDoubleSided = true
        textGeometry.chamferRadius = 0.01
        
        
        // NODE
        let (minBound, maxBound) = textGeometry.boundingBox
        let textNode = SCNNode(geometry: textGeometry)
        textNode.pivot = SCNMatrix4MakeTranslation( (maxBound.x - minBound.x)/2, minBound.y, Float(textGeometry.extrusionDepth/2))
        textNode.scale = SCNVector3(0.2, 0.2, 0.2)
        
        // PARENT NODE
        textNodeParent.addChildNode(textNode)
        textNodeParent.constraints = [billboardConstraint]
        
        sceneView.scene.rootNode.addChildNode(textNodeParent)
        textNodeParent.position = SCNVector3(
            hitResult.worldTransform.columns.3.x,
            hitResult.worldTransform.columns.3.y,
            hitResult.worldTransform.columns.3.z
        )
        
        chosenObject = mostAccuratePrediction
    }



    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        // Enable plane detection
        configuration.planeDetection = .horizontal
        // configuration.worldAlignment = .gravityAndHeading

        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

extension UIFont {
    func withTraits(traits:UIFontDescriptor.SymbolicTraits...) -> UIFont {
        let descriptor = self.fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits))
        return UIFont(descriptor: descriptor!, size: 0)
    }
}



