//
//  IntroTableViewCell.swift
//  aquae
//
//  Created by Pietro Santececca on 07/01/16.
//  Copyright © 2016 Pietro Santececca. All rights reserved.
//

import UIKit

@IBDesignable
class IntroTableViewCell: UITableViewCell {
    
    @IBInspectable dynamic var poiType:Int = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
