//
//  IntroTableViewController.swift
//  aquae
//
//  Created by Pietro Santececca on 05/01/16.
//  Copyright © 2016 Pietro Santececca. All rights reserved.
//

import UIKit

class IntroTableViewController: UITableViewController {
    
    var selectedType: PoiType?

    @IBOutlet weak var numberOfFountains: UILabel! {
        didSet {
            numberOfFountains.text = "\(ModelManager.instance.countOfPoisByType(1))"
        }
    }
    
    @IBOutlet weak var numberOfInfoPoints: UILabel! {
        didSet {
            numberOfInfoPoints.text = "\(ModelManager.instance.countOfPoisByType(3))"
        }
    }
    
    @IBOutlet weak var numberOfToilets: UILabel! {
        didSet {
            numberOfToilets.text = "\(ModelManager.instance.countOfPoisByType(2))"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        let logo = UIImage(named: "logo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath) as! IntroTableViewCell
        if selectedCell.poiType != 0 {
            selectedType = PoiType(rawValue: selectedCell.poiType)
            self.performSegue(withIdentifier: "fromIntroToMap", sender: self)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromIntroToMap" {
            if let nav = segue.destination as? UINavigationController {
                if let destinationVC = nav.viewControllers[0] as? MapViewController {
                    destinationVC.enabledPoiTypes.append(selectedType!)
                }
            }
        }
    }

    
}
