//
//  ModelManager.swift
//  DataBaseDemo
//
//  Created by Krupa-iMac on 05/08/14.
//  Copyright (c) 2014 TheAppGuruz. All rights reserved.
//

import UIKit
import MapKit

let sharedInstance = ModelManager()

class ModelManager: NSObject {
    
    var database: FMDatabase? = nil
    let defaultDistrict = "ROME"
    
    class var instance: ModelManager {
        sharedInstance.database = FMDatabase(path: Util.getPath("aquae.db"))
        return sharedInstance
    }
    
    func countOfPoisByType(_ type: Int) -> Int {
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT COUNT(*) FROM pois WHERE type = \(type)", withArgumentsIn: nil)
        var result = -1
        if (resultSet != nil) {
            while resultSet.next() {
                result = Int(resultSet.int(forColumnIndex: 0))
            }
        }
        sharedInstance.database!.close()
        
        return result
    }
    
    func getPoisByType(_ type: Int) -> [Poi] {
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM pois WHERE type = \(type)", withArgumentsIn: nil)
        let index = "id"
        let name = "name"
        let info = "info"
        let extraInfo = "extra_info"
        let address = "address"
        let district = "district"
        let status = "status"
        let latitude = "latitude"
        let longitude = "longitude"
        
        var allPois = Array<Poi>()
        
//        let poi = Poi(id:1,
//            type: PoiType.Fountain,
//            address: "Wilhelmstraße 55",
//            location: CLLocationCoordinate2D(latitude: 52.514785, longitude: 13.382798))
//        poi.district = "BERLIN"
//        poi.status = true
//        allPois.append(poi);
        
        if (resultSet != nil) {
            while resultSet.next() {
                let sLatitude = resultSet.string(forColumn: latitude).replacingOccurrences(of: ",", with: ".")
                let sLongitude = resultSet.string(forColumn: longitude).replacingOccurrences(of: ",", with: ".")
                
                let poi = Poi(id:resultSet.int(forColumn: index),
                    type: PoiType(rawValue: type)!,
                    address: resultSet.string(forColumn: address),
                    location: CLLocationCoordinate2D(latitude: (sLatitude as NSString).doubleValue , longitude: (sLongitude as NSString).doubleValue))
                
                poi.name = resultSet.string(forColumn: name)
                poi.info = resultSet.string(forColumn: info)
                poi.extraInfo = resultSet.string(forColumn: extraInfo)
                poi.district = resultSet.string(forColumn: district)
                if poi.district == "" {
                    if poi.name != "" {
                        poi.district = poi.name
                    }
                    else {
                        poi.district = defaultDistrict
                    }
                }
                poi.status = resultSet.bool(forColumn: status)
                
                allPois.append(poi);
            }
        }
        sharedInstance.database!.close()
        
        return allPois;
    }
    
}
