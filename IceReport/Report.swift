//
//  Report.swift
//  IceReport
//
//  Created by Andrew Thom on 1/21/17.
//  Copyright © 2017 Andrew J. Thom. All rights reserved.
//

import Foundation

class Report {
    var latitude : Double
    var longitude : Double
    var date : Date?
    var userId : Int
    var inches : String
    
    init(_ lat : Double, _ long : Double, _ timestamp : Date?, _ userId : Int, _ inches: String) {
        self.latitude = lat
        self.longitude = long
        self.date = timestamp
        self.userId = userId
        self.inches = inches;
    }
}
