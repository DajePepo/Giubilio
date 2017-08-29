//
//  Poi.swift
//  Mappoi
//
//  Created by Pietro Santececca on 24/07/15.
//  Copyright (c) 2015 Pietro Santececca. All rights reserved.
//

import Foundation
import SKMaps

enum PoiType: Int {
    case fountain = 1
    case toilet = 2
    case infoPoint = 3
}

class Poi: NSObject {
    var id: Int32!
    var location: CLLocationCoordinate2D!
    var type: PoiType!
    var address: String!
    var name = ""
    var district = ""
    var info = ""
    var extraInfo = ""
    var status = true
    
    init(id: Int32, type: PoiType, address: String, location: CLLocationCoordinate2D) {
        self.id = id
        self.location = location
        self.type = type
        self.address = address
        
        super.init()
    }

}
