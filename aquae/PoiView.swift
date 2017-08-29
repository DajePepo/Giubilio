//
//  PoiView.swift
//  aquae
//
//  Created by Pietro Santececca on 07/01/16.
//  Copyright © 2016 Pietro Santececca. All rights reserved.
//

import UIKit
import SKMaps

class PoiView: SKAnnotation {
    
    var poi: Poi!
    
    var isSelected: Bool {
        didSet {
            var imageName: String?
            var reuseIdentifier: String?
            
            if isSelected {
                switch poi.type! {
                case .fountain:
                    imageName = "fountainPinSelected"
                    reuseIdentifier = "selectedFountainPinID"
                case .toilet:
                    imageName = "toiletPinSelected"
                    reuseIdentifier = "selectedToiletPinID"
                case .infoPoint:
                    imageName = "infoPinSelected"
                    reuseIdentifier = "selectedInfoPinID"
                }
            }
            else if !isSelected {
                switch poi.type! {
                case .fountain:
                    imageName = "fountainPin"
                    reuseIdentifier = "fountainPinID"
                case .toilet:
                    imageName = "toiletPin"
                    reuseIdentifier = "toiletPinID"
                case .infoPoint:
                    imageName = "infoPin"
                    reuseIdentifier = "infoPinID"
                }
            }
            
            if imageName != nil && reuseIdentifier != nil {
                let view = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 45.0, height: 45.0))
                view.image = UIImage(named: imageName!)
                let annotationView = SKAnnotationView(view: view, reuseIdentifier: reuseIdentifier!)
                self.annotationView = annotationView
            }
        }
    }
    
    var subtitle: String? {
        return poi.address
    }
    
    init(poi: Poi) {
        self.poi = poi
        self.isSelected = false
        
        super.init()
        self.identifier = poi.id
        self.location = poi.location
    }

}
