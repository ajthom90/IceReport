//
//  RefreshMapDelegate.swift
//  IceReport
//
//  Created by Andrew Thom on 1/23/17.
//  Copyright © 2017 Andrew J. Thom. All rights reserved.
//

import Foundation
import MapKit

protocol IceReportMapDelegate {
    func refreshMap() -> Void
    func set(mapType : MKMapType)
}
