//
//  MapTypeMapper.swift
//  IceReport
//
//  Created by Andrew Thom on 1/23/17.
//  Copyright © 2017 Andrew J. Thom. All rights reserved.
//

import Foundation
import MapKit

class MapTypeMapper {
    static func mapType(for number : Int) -> MKMapType {
        if number == 0 {
            return .standard
        }
        if number == 1 {
            return .satellite
        }
        if number == 2 {
            return .hybrid
        }
        return .standard
    }
    
    static func mapType(for type : MKMapType) -> Int {
        if type == .standard {
            return 0
        }
        if type == .satellite {
            return 1
        }
        if type == .hybrid {
            return 2
        }
        return 0
    }
}
