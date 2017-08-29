//
//  Util.swift
//  DemoProject
//
//  Created by Krupa-iMac on 24/07/14.
//  Copyright (c) 2014 TheAppGuruz. All rights reserved.
//

import UIKit
import SKMaps

class Util: NSObject {
    
    static let romeCenter = CLLocationCoordinate2DMake(41.900532, 12.484149)
    static let berlinCenter = CLLocationCoordinate2DMake(52.522359, 13.406144)
    static let fakePosition = romeCenter
    static let maxDistance:Double = 1000000
    static let youAreNotHereTitle = "Are you in Rome now?"
    static let youAreNotHereMessage = "I don't think so.\nThis app doesn't work out of Rome so to give you a chance to test the app features right now I’ll pretend you are in the centre of Rome."
    static let youAreNotHereButtonText = "Ok, thanks."
    static let noExtraInfo = "There are not extra info for this item"
    
    class func getPath(_ fileName: String) -> String {
        let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let urlString = URL(fileURLWithPath: filePath).appendingPathComponent(fileName)
        return urlString.path
    }
    
    class func copyFile(_ fileName: NSString) {
        let dbPath: String = getPath(fileName as String)
        let fromPath: String? = ((Bundle.main.resourcePath)! as NSString).appendingPathComponent(fileName as String)
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: dbPath) || !fileManager.contentsEqual(atPath: fromPath!, andPath:dbPath) {
            var errorValue = false
            do {
                try fileManager.copyItem(atPath: fromPath!, toPath: dbPath)
            }
            catch let errorDescription as NSError {
                errorValue = true
                print("Error during database loading: " + errorDescription.localizedDescription)
            }
            catch {
                errorValue = true
                print("Generic error")
            }
            
            if !errorValue {
                print("Database loaded with success")
            }
        }
    }
    
    class func distanceBetweenTwoPoints(_ firstPoint: CLLocationCoordinate2D, secondPoint: CLLocationCoordinate2D) -> CLLocationDistance {
        
        let firstPointLocation = CLLocation(latitude: firstPoint.latitude, longitude: firstPoint.longitude)
        let secondPointLocation = CLLocation(latitude: secondPoint.latitude, longitude: secondPoint.longitude)
        let distance = firstPointLocation.distance(from: secondPointLocation)
        
        return distance
    }
    
    class func getCurrentPositionOrFakePosition() -> (currentPosition: CLLocationCoordinate2D, isRealPosition: Bool) {
        let distance = Util.distanceBetweenTwoPoints(SKPositionerService.sharedInstance().currentCoordinate, secondPoint: fakePosition)
        if distance > maxDistance {
            return (fakePosition, false)
        }
        else {
            return (SKPositionerService.sharedInstance().currentCoordinate, true)
        }
    }
    
    class func screenHeight() -> CGFloat {
        let bounds = UIScreen.main.bounds
        return bounds.size.height
    }
    
    class func screenWidth() -> CGFloat {
        let bounds = UIScreen.main.bounds
        return bounds.size.width
    }
}
