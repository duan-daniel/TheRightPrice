//
//  MapARViewController.swift
//  TheRightPrice
//
//  Created by Daniel Duan on 4/14/19.
//  Copyright © 2019 Daniel Duan. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import ARCL

import Firebase
import FirebaseFirestore

class MapARViewController: UIViewController {
    var sceneLocationView = SceneLocationView()
    
    var docRef: DocumentReference!
    var db: Firestore!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        db = Firestore.firestore()

        sceneLocationView.run()
        view.addSubview(sceneLocationView)
        // Do any additional setup after loading the view.
        addNodes()
    }
    
    func addNodes() {
        
        db.collection("locations").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let lat = document.get("latitude")! as! Double
                    let long = document.get("longitude")! as! Double
                    
                    let name = document.get("name")! as! String
                    let coordinate = CLLocationCoordinate2D(latitude: lat as! CLLocationDegrees, longitude: long as! CLLocationDegrees)
                   
                    let location = CLLocation(coordinate: coordinate, altitude: 0)
                    let image = UIImage(named: "pin")!
                    
                    let test = self.buildViewNode(latitude: lat as! CLLocationDegrees, longitude: long as! CLLocationDegrees, altitude: 200, text: name)
                    
                    self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: test)

                }
            }
        }

    }
    
    func buildViewNode(latitude: CLLocationDegrees, longitude: CLLocationDegrees,
                       altitude: CLLocationDistance, text: String) -> LocationAnnotationNode {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let location = CLLocation(coordinate: coordinate, altitude: altitude)

        var xComponent = latitude + 37.32565
        var yComponent = longitude + 122.04271
        var distance = (xComponent * xComponent + yComponent * yComponent).squareRoot()
        let y = Double(round(10*distance)/10)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 60))
        label.backgroundColor = UIColor(white: 1, alpha: 0.5)
        
        label.text = "\(text)\n\(y) meters"
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        
        label.backgroundColor = .white
        label.textAlignment = .center
        return LocationAnnotationNode(location: location, view: label)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sceneLocationView.frame = view.bounds
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
