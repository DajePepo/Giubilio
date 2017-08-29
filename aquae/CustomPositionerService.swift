//
//  CustomPositionerService.swift
//  aquae
//
//  Created by Pietro Santececca on 10/01/16.
//  Copyright © 2016 Pietro Santececca. All rights reserved.
//

import UIKit
import SKMaps

class CustomPositionerService: SKPositionerService {
    
//    override class func sharedInstance() -> CustomPositionerService! {
//        return super.sharedInstance() as! CustomPositionerService
//    }

    override class func sharedInstance() -> CustomPositionerService! {
        struct Static {
            static let instance = CustomPositionerService()
        }
        return Static.instance
    }

//    override var currentCoordinate: CLLocationCoordinate2D {
//        get {
//            let distance = Util.distanceBetweenTwoPoints(super.currentCoordinate, secondPoint: romeCenter)
//            if distance > maxDistance {
//                return romeCenter
//            }
//            else {
//                return super.currentCoordinate
//            }
//        }
//    }
    
    func addRomeCenterAsUserPosition(_ mapView: SKMapView) {
        
        // remove eventually previous user point position
        mapView.removeAnnotation(withID: 0)
        
        //create our view
        let imageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 30.0, height: 30.0))
        imageView.image = UIImage(named: "customUserPosition")
        
        //create the SKAnnotationView
        let view = SKAnnotationView(view: imageView, reuseIdentifier: "userPositionViewID")
        
        //create the annotation
        let viewAnnotation = SKAnnotation()
        
        //set the custom view
        viewAnnotation.annotationView = view
        viewAnnotation.identifier = 0
        viewAnnotation.location = CLLocationCoordinate2DMake(Util.fakePosition.latitude, Util.fakePosition.longitude)
        
        let animationSettings = SKAnimationSettings()
        mapView.addAnnotation(viewAnnotation, with: animationSettings)
    }

}
