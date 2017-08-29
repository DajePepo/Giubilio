//
//  PoiTypeButton.swift
//  aquae
//
//  Created by Pietro Santececca on 09/01/16.
//  Copyright © 2016 Pietro Santececca. All rights reserved.
//

import UIKit

class PoiTypeButton: UIButton {

    var poiType:PoiType?
    
    var isActive = false {
        didSet {
            var imageName: String?
            
            if isActive {
                switch poiType! {
                case .fountain:
                    imageName = "fountainButton"
                case .toilet:
                    imageName = "toiletButton"
                case .infoPoint:
                    imageName = "infoButton"
                }
            }
            
            else if !isActive {
                switch poiType! {
                case .fountain:
                    imageName = "fountainButtonDisable"
                case .toilet:
                    imageName = "toiletButtonDisable"
                case .infoPoint:
                    imageName = "infoButtonDisable"
                }
                
            }
            
            if imageName != nil {
                if let image = UIImage(named: imageName!) {
                    self.setImage(image, for: UIControlState())
                }
            }
        }
    }

}
