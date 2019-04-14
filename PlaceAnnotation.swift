//
//  PlaceAnnotation.swift
//  TheRightPrice
//
//  Created by Daniel Duan on 4/14/19.
//  Copyright © 2019 Daniel Duan. All rights reserved.
//

import Foundation
import MapKit

class PlaceAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    
    init(location: CLLocationCoordinate2D, title: String) {
        self.coordinate = location
        self.title = title
        
        super.init()
    }
}

