//
//  MapViewController.swift
//  aquae
//
//  Created by Pietro Santececca on 17/11/15.
//  Copyright © 2015 Pietro Santececca. All rights reserved.
//

import UIKit
import SKMaps

class MapViewController: UIViewController, SKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: SKMapView!
    @IBOutlet weak var userLocationButton: UIButton! {
        didSet {
            userLocationButton.addTarget(self, action: #selector(MapViewController.showUserLocation), for: .touchUpInside)
        }
    }
    @IBOutlet weak var fountainButton: PoiTypeButton! {
        didSet {
            fountainButton.poiType = PoiType.fountain
            fountainButton.isActive = false
        }
    }
    @IBOutlet weak var infoPointButton: PoiTypeButton! {
        didSet {
            infoPointButton.poiType = PoiType.infoPoint
            infoPointButton.isActive = false
        }
    }
    @IBOutlet weak var toiletButton: PoiTypeButton!{
        didSet {
            toiletButton.poiType = PoiType.toilet
            toiletButton.isActive = false
        }
    }
    
    var enabledPoiTypes = [PoiType]()
    var allPois = [Poi]()
    var selectedAnnotation:SKAnnotation?
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barStyle = UIBarStyle.blackTranslucent
        
        let logo = UIImage(named: "logo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView

        mapView.settings.rotationEnabled = false;
        //mapView.settings.followUserPosition = true;
        mapView.settings.headingMode = SKHeadingMode.rotatingHeading;
        mapView.settings.showCompass = false
        mapView.mapScaleView.isHidden = true
        mapView.delegate = self
        
        let region = SKCoordinateRegion(center: Util.romeCenter, zoomLevel: 15)
        mapView.visibleRegion = region
        
        fountainButton.isActive = enabledPoiTypes.contains(fountainButton.poiType!) ? true : false
        infoPointButton.isActive = enabledPoiTypes.contains(infoPointButton.poiType!) ? true : false
        toiletButton.isActive = enabledPoiTypes.contains(toiletButton.poiType!) ? true : false
        
        for poiType in enabledPoiTypes {
            addPoisByType(poiType)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(selectedAnnotation != nil) {
            mapView.visibleRegion.center = selectedAnnotation!.location
            mapView.visibleRegion.zoomLevel = 15
        }
        if timer != nil { // Se è diverso da nil vuol dire che l'ho fatto partire in precedenza quindi la posizione dell'utente è visualizzata
            timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(MapViewController.updateUserPosition), userInfo: nil, repeats: true)
        }
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if timer != nil {
            timer!.invalidate()
        }
    }
    
    func mapView(_ mapView:SKMapView!, didSelect annotation:SKAnnotation!) {
        
        if annotation as? PoiView != nil {
            
            // Deselect all other annotations
            self.deselectAllAnnotaions()
            
            // Selected Annotation View
            let coloredView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 45.0, height: 45.0))
            coloredView.image = UIImage(named: "selectedPin")
            let view = SKAnnotationView(view: coloredView, reuseIdentifier: "selectedViewID")
            annotation.annotationView = view
            (annotation as! PoiView).isSelected = true
            mapView.updateAnnotation(annotation)
            
            // Annotation info
            mapView.calloutView.titleLabel.text = (annotation as! PoiView).poi.address;
            mapView.calloutView.subtitleLabel.text = (annotation as! PoiView).poi.district;
            
            // Right button
            mapView.calloutView.rightButton.addTarget(self, action:#selector(MapViewController.goToPoiDetail(_:)), for: .touchUpInside)
            mapView.calloutView.rightButton.setImage(UIImage(named:"right_arrow"), for: UIControlState())
            mapView.calloutView.rightButton.frame = CGRect(x: 255, y: 9, width: 30, height: 30)
            mapView.calloutView.rightButton.tag = Int("\((annotation as! PoiView).identifier)") ?? -1
            
            // Left button
            mapView.calloutView.leftButton.setImage(UIImage(named:"colosseum"), for: UIControlState())
            mapView.calloutView.leftButton.frame = CGRect(x: 12, y: 4, width: 40, height: 40)
            
            mapView.showCallout(for: annotation, withOffset: CGPoint(x: 0, y: 30), animated: true);
        }
    }
    
    func mapView(_ mapView: SKMapView!, didTapAt coordinate: CLLocationCoordinate2D) {
        mapView.hideCallout()
        self.deselectAllAnnotaions()
    }
    
    func showUserLocation() {
        let positionInfo: (currentPosition:CLLocationCoordinate2D, isRealPosition:Bool) = Util.getCurrentPositionOrFakePosition()
        let newRegion = SKCoordinateRegion(center: positionInfo.currentPosition, zoomLevel: 15)
        mapView.visibleRegion = newRegion
        if !positionInfo.isRealPosition {
            CustomPositionerService.sharedInstance().addRomeCenterAsUserPosition(mapView)
            
            let alertController = UIAlertController(title: Util.youAreNotHereTitle, message: Util.youAreNotHereMessage, preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: Util.youAreNotHereButtonText, style: UIAlertActionStyle.default,handler: nil))   
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(MapViewController.updateUserPosition), userInfo: nil, repeats: true)
        }
    }
    
    func deselectAllAnnotaions() {
        for annotation in mapView.annotations {
            let poiView = annotation as? PoiView
            if poiView != nil && poiView!.isSelected {
                poiView!.isSelected = false
                mapView.updateAnnotation(annotation as! PoiView)
            }
        }
    }
    
    @IBAction func addOrRemovePois(_ sender: PoiTypeButton!) {
        sender.isActive = !sender.isActive
        if sender.isActive {
            addPoisByType(sender.poiType!)
        }
        else {
            removePoisByType(sender.poiType!)
        }
    }
    
    func addPoisByType(_ type: PoiType) {
        
        // Add poiType to the enabled poi types array
        if !enabledPoiTypes.contains(type){
            enabledPoiTypes.append(type)
        }
        
        // Load fountains from local db
        let poisToAdd = ModelManager.instance.getPoisByType(type.rawValue)
        
        // Add loaded fountains (annotation) on the map
        for poi in poisToAdd {
            
            // Add poi to general array set
            allPois.append(poi)
            
            // Annotation View
            let poiView = PoiView(poi: poi)
            poiView.isSelected = false
            
            // Annotation settings
            let animationSettings = SKAnimationSettings()
            
            // Add annotation
            mapView.addAnnotation(poiView, with: animationSettings)
        }
        
        
    }

    func removePoisByType(_ type: PoiType) {
        
        // Remove poiType to the enabled poi types array
        for i in 0 ..< enabledPoiTypes.count {
            if enabledPoiTypes[i].rawValue == type.rawValue {
                enabledPoiTypes.remove(at: i)
                break
            }
        }
        
        // Look for all pois to remove
        let allAnnotation = mapView.annotations
        if allAnnotation != nil {
            for annotation in allAnnotation! {
                let poiView = annotation as? PoiView
                if poiView != nil && poiView!.poi.type == type {
                    
                    // Remove poi from general array set
                    for i in 0 ..< allPois.count {
                        if allPois[i].id == poiView!.poi.id {
                            allPois.remove(at: i)
                            break
                        }
                    }
                    
                    // Add annotation poi on the map
                    mapView.removeAnnotation(withID: (annotation as AnyObject).identifier)
                }
            }
        }
    }

    func goToPoiDetail(_ sender: UIButton!) {
        self.performSegue(withIdentifier: "fromMapToDetail", sender: sender)
    }
    
    func updateUserPosition() {
        //print("1. Aggiorno la posizione dell'utente")
        Util.getCurrentPositionOrFakePosition()
    }
    
    @IBAction func goToPoiList(_ sender: UIBarButtonItem!) {
        self.performSegue(withIdentifier: "fromMapToList", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromMapToDetail" {
            for annotation in mapView.annotations {
                if annotation as? PoiView != nil {
                    let annotationId = Int("\((annotation as! PoiView).identifier)") ?? -1
                    if annotationId != -1 && annotationId == (sender! as AnyObject).tag {
                        selectedAnnotation = annotation as? SKAnnotation
                        (segue.destination as? DetailViewController)?.poi = (annotation as! PoiView).poi
                    }
                }
            }
        }
        else if segue.identifier == "fromMapToList" {
            if let nav = segue.destination as? UINavigationController {
                if let destinationVC = nav.viewControllers[0] as? ListTableViewController {
                    destinationVC.items = allPois
                    destinationVC.enabledPoiTypes = enabledPoiTypes
                }
            }
        }
    }

}

