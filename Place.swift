//
//  Place.swift
//  TheRightPrice
//
//  Created by Daniel Duan on 4/14/19.
//  Copyright © 2019 Daniel Duan. All rights reserved.
//

import Foundation
import CoreLocation
import HDAugmentedReality

class Place: ARAnnotation {
    let reference: String
    let placeName: String
    let address: String
    var phoneNumber: String?
    var website: String?
    
    var infoText: String {
        get {
            var info = "Address: \(address)"
            
            if phoneNumber != nil {
                info += "\nPhone: \(phoneNumber!)"
            }
            
            if website != nil {
                info += "\nweb: \(website!)"
            }
            return info
        }
    }
    
    init(location: CLLocation, reference: String, name: String, address: String) {
        placeName = name
        self.reference = reference
        self.address = address
        
        super.init()
        
        self.location = location
    }
    
    override var description: String {
        return placeName
    }
}
