//
//  IceReportAnnotation.swift
//  IceReport
//
//  Created by Andrew Thom on 1/21/17.
//  Copyright © 2017 Andrew J. Thom. All rights reserved.
//

import Foundation
import MapKit

class IceReportAnnotation : MKPointAnnotation {
    
    open var reportIndex : Int = 0
    open var reuseIdentifier = "greenPin"
    open var annotationColor = UIColor.green
}
