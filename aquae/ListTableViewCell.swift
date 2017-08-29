//
//  ListTableViewCell.swift
//  aquae
//
//  Created by Pietro Santececca on 21/12/15.
//  Copyright © 2015 Pietro Santececca. All rights reserved.
//

import UIKit
import SKMaps

class ListTableViewCell: UITableViewCell {
    
    var item: Poi? {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet weak var itemAddress: UILabel!
    @IBOutlet weak var itemDistrict: UILabel!
    @IBOutlet weak var itemDistance: UILabel!
    @IBOutlet weak var itemImage: UIImageView!
    
    func updateUI() {
        
        // reset any existing information
        itemAddress?.attributedText = nil
        itemDistrict?.attributedText = nil
        itemDistance?.attributedText = nil
        
        // load new information from our item (if any)
        if let item = self.item
        {
            itemAddress?.text = item.address
            itemDistrict?.text = item.district
            
            // calculate item distance from user position
            let itemLocation = CLLocation(latitude: item.location.latitude, longitude: item.location.longitude)
            let itemUserLocation = CLLocation(latitude: Util.getCurrentPositionOrFakePosition().currentPosition.latitude, longitude: Util.getCurrentPositionOrFakePosition().currentPosition.longitude)
            let distance = Int(itemLocation.distance(from: itemUserLocation))
            if distance >= 1000 {
                itemDistance?.text = "\(Int(distance / 1000))Km"
                if distance > 1000 {
                    itemDistance?.text = (itemDistance?.text)! + " \(distance % 1000)m"
                }
            }
            else {
                itemDistance?.text = "\(distance)m"
            }
        }
        
        // set image by poi type
        var imageName: String?
        
        switch item!.type! {
        case .fountain:
            imageName = "circularFountainIcon"
        case .toilet:
            imageName = "circularToiletIcon"
        case .infoPoint:
            imageName = "circularInfoPointIcon"
        }
        
        if imageName != nil {
            itemImage.image = UIImage(named: imageName!)
        }
    }
    
}
