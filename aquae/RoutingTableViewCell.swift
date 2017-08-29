//
//  RoutingTableViewCell.swift
//  aquae
//
//  Created by Pietro Santececca on 28/12/15.
//  Copyright © 2015 Pietro Santececca. All rights reserved.
//

import UIKit
import SKMaps

class RoutingTableViewCell: UITableViewCell {

    var routeAdvice: SKRouteAdvice? {
        didSet {
            updateUI()
        }
    }
    
    fileprivate struct Sign {
        static let invalid = "invalid"
        static let straightAhead = "straightAhead"
        static let slightRight = "slightRight"
        static let slightLeft = "slightLeft"
        static let turnRight = "turnRight"
        static let turnLeft = "turnLeft"
        static let uTurn = "uTurn"
        static let tStreet = "tStreet"
        static let bifurcation = "bifurcation"
        static let roundabout = "roundabout"
        
        static func getImageName(_ imageCode: SKStreetDirection) -> String {
            switch imageCode {
                case .invalid:
                    return invalid
                case .straightAhead:
                    return straightAhead
                case .slightRight:
                    return slightRight
                case .slightLeft:
                    return slightLeft
                case .left:
                    return turnLeft
                case .right:
                    return turnRight
                case .hardLeft:
                    return turnLeft
                case .hardRight:
                    return turnRight
                case .uTurn:
                    return uTurn
                case .tStreet:
                    return tStreet
                case .bifurcation:
                    return bifurcation
                case .ignoreAngle:
                    return uTurn // Creare immagine -> cazzo è "ignore angle"
                case .roundabout:
                    return roundabout
            }
        }
    }
    
    @IBOutlet weak var routeAdviceSign: UIImageView!
    @IBOutlet weak var routeAdviceInstruction: UILabel!
    @IBOutlet weak var routeAdviceDistance: UILabel!
    
    func updateUI() {
        
        // reset any existing information
        routeAdviceSign?.image = nil
        routeAdviceInstruction?.attributedText = nil
        routeAdviceDistance?.attributedText = nil
        
        // load new information from our route advice (if any)
        if let routeAdvice = self.routeAdvice
        {
            routeAdviceInstruction?.text = routeAdvice.adviceInstruction
            routeAdviceDistance?.text = "\(Int(routeAdvice.distanceToAdvice)) m"
            routeAdviceSign?.image = UIImage(named: Sign.getImageName(routeAdvice.streetDirection))
        }
        
    }

}
