//
//  ListTableViewController.swift
//  aquae
//
//  Created by Pietro Santececca on 21/12/15.
//  Copyright © 2015 Pietro Santececca. All rights reserved.
//

import UIKit
import SKMaps

class ListTableViewController: UITableViewController {
    
    var items:[Poi]?
    var selectedItem:Poi?
    var enabledPoiTypes:[PoiType]?
    
    fileprivate struct Storyboard {
        static let CellReuseIdentifier = "ItemIdentifier"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let logo = UIImage(named: "logo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Ordino la lista in base alla distanza dalla posizione dell'utente
        if items != nil {
            items!.sort(by: {
                
                let itemUserLocation = CLLocation(latitude: Util.getCurrentPositionOrFakePosition().currentPosition.latitude, longitude: Util.getCurrentPositionOrFakePosition().currentPosition.longitude)
                
                let zeroItemLocation = CLLocation(latitude: $0.location.latitude, longitude: $0.location.longitude)
                let zeroDistance = zeroItemLocation.distance(from: itemUserLocation)
                
                let oneItemLocation = CLLocation(latitude: $1.location.latitude, longitude: $1.location.longitude)
                let oneDistance = oneItemLocation.distance(from: itemUserLocation)
                
                return zeroDistance < oneDistance
            })
        }
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if items != nil {
            return items!.count
        }
        else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if items != nil {
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellReuseIdentifier, for: indexPath) as! ListTableViewCell
            cell.item = items![indexPath.row]
            return cell
        }
        else {
            return UITableViewCell()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if items != nil {
            selectedItem = items![indexPath.row]
            self.performSegue(withIdentifier: "fromListToDetail", sender: self)
        }
    }
    
    
    // MARK: - Navigation
    
    @IBAction func goToFountainMap(_ sender: UIBarButtonItem!) {
        self.performSegue(withIdentifier: "fromListToMap", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier! == "fromListToDetail") {
            (segue.destination as? DetailViewController)?.poi = selectedItem
        }
        else if (segue.identifier! == "fromListToMap") {
            if let nav = segue.destination as? UINavigationController {
                if let destinationVC = nav.viewControllers[0] as? MapViewController {
                    if enabledPoiTypes != nil {
                        destinationVC.enabledPoiTypes = enabledPoiTypes!
                    }
                }
            }
        }
    }

}
