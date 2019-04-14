//
//  MapViewController.swift
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

class MapViewController: UIViewController {
    
    var POIs = [CLLocation]()
    
    @IBOutlet weak var button: UIButton!
    var sceneLocationView = SceneLocationView()
    
    var arViewController: ARViewController!
    
    var docRef: DocumentReference!
    var db: Firestore!
    
    let locationManager = CLLocationManager()

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        db = Firestore.firestore()

        super.viewDidLoad()
        
        self.mapView.showsUserLocation = true;

        
        loadData()
        // Do any additional setup after loading the view.
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
    }
    
    func loadData() {
        db.collection("locations").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let lat = document.get("latitude")!
                    let long = document.get("longitude")!
                    let name = document.get("name")! as! String
                    let price = document.get("price")! as! String
                    let newTitle = "\(name)" + "-$" + "\(price)"
                    let trimmedString = newTitle.trimmingCharacters(in: .whitespaces)

                    let coord = CLLocationCoordinate2D(latitude: lat as! CLLocationDegrees, longitude: long as! CLLocationDegrees)
                    print("creating annotation")
                    let annotation = PlaceAnnotation(location: coord, title: trimmedString)

                    DispatchQueue.main.async {
                        self.mapView.addAnnotation(annotation)
                    }

                    let poiLocation = CLLocation(latitude: lat as! CLLocationDegrees, longitude: long as! CLLocationDegrees)
                    print("location: \(poiLocation)")
                    self.POIs.append(poiLocation)
                }
            }
        }
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

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //1
        if locations.count > 0 {
            let location = locations.last!
            print("Accuracy: \(location.horizontalAccuracy)")
            
            //2
            if location.horizontalAccuracy < 100 {
                //3
                manager.stopUpdatingLocation()
                let span = MKCoordinateSpan(latitudeDelta: 0.014, longitudeDelta: 0.014)
                let region = MKCoordinateRegion(center: location.coordinate, span: span)
                mapView.region = region
                
                //2
//                for CLLocation in POIs {
//                    print("going here")
//                    //3
//                    let lat = CLLocation.coordinate.latitude
//                    let long = CLLocation.coordinate.longitude
////                    let reference = placeDict.object(forKey: "reference") as! String
////                    let name = placeDict.object(forKey: "name") as! String
////                    let address = placeDict.object(forKey: "vicinity") as! String
//
//                    // let location = CLLocation(latitude: lat, longitude: long)
//                    //4
////                    let place = Place(location: location, reference: reference, name: name, address: address)
////                    self.places.append(place)
////                    //5
//                    let coord = CLLocationCoordinate2D(latitude: lat as! CLLocationDegrees, longitude: long as! CLLocationDegrees)
//                    let annotation = PlaceAnnotation(location: coord)
//                    //6
//                    DispatchQueue.main.async {
//                        self.mapView.addAnnotation(annotation)
//                    }
//                }
            }
        }
    }
}

