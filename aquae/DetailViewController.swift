//
//  DetailViewController.swift
//  aquae
//
//  Created by Pietro Santececca on 26/11/15.
//  Copyright © 2015 Pietro Santececca. All rights reserved.
//

import UIKit
import SKMaps

class DetailViewController: UIViewController, SKMapViewDelegate, SKRoutingDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {

    var isMapBig = false
    var centerWhenMapIsSmall:CLLocationCoordinate2D?
    var zoomWhenMapIsSmall:Float?
    var centerWhenMapIsBig:CLLocationCoordinate2D?
    var zoomWhenMapIsBig:Float?
    var constant_1:CGFloat?
    var constant_2:CGFloat = 65.0 // table header height
    var constant_3:CGFloat?
    var navigationBarHeight: CGFloat?
    var statusBarHeight: CGFloat?
    var continueRotaring:Bool = true
    var routeAdvices:[SKRouteAdvice]?
    var tapToCollapseGesture: UITapGestureRecognizer?
    var positionInfo: (currentPosition: CLLocationCoordinate2D, isRealPosition: Bool)?
    var timer: Timer?

    
    fileprivate struct Storyboard {
        static let CellReuseIdentifier = "RouteAdviceIdentifier"
    }
    
    @IBOutlet weak var detailMapView: SKMapView! {
        didSet {
            detailMapView.settings.rotationEnabled = false;
            //detailMapView.settings.followUserPosition = true;
            detailMapView.settings.headingMode = SKHeadingMode.rotatingHeading;
            detailMapView.settings.showCompass = false
            detailMapView.mapScaleView.isHidden = true
            detailMapView.delegate = self
        }
    }
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var spaceBetweenTopDetail: NSLayoutConstraint! {
        didSet {
            constant_1 = spaceBetweenTopDetail.constant
        }
    }
    
    @IBOutlet weak var spaceBetweenBottomMap: NSLayoutConstraint!
    
    @IBOutlet weak var spaceBetweenBottomDetail: NSLayoutConstraint!
    
    @IBOutlet weak var loaderContainer: UIView!
    @IBOutlet weak var loader: CircularLoaderView!
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
        }
    }
    
    @IBOutlet weak var routingTableView: UITableView! {
        didSet {
            routingTableView.delegate = self
            routingTableView.dataSource = self
            routingTableView.estimatedRowHeight = routingTableView.rowHeight
            routingTableView.rowHeight = UITableViewAutomaticDimension
        }
    }
    
    @IBOutlet weak var navigationTitleButton: UIButton!
    
    var blurView: UIVisualEffectView?
    
    @IBOutlet weak var extraInfoContainer: UIView!
    @IBOutlet weak var extraInfoContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var extraInfoLabel: UILabel!
    @IBOutlet weak var extraInfoContainerPaddingTop: NSLayoutConstraint!
    
    
    @IBAction func showPoiExtraInfo(_ sender:UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            if blurView == nil {
                let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.dark)
                blurView = UIVisualEffectView(effect: darkBlur)
                blurView!.frame = self.view.bounds
            }
            blurView!.alpha = 0
            extraInfoLabel.alpha = 0
            self.view.insertSubview(blurView!, belowSubview: extraInfoContainer)
            
            extraInfoContainerHeight.constant = self.constant_1! + 10
            extraInfoContainerPaddingTop.constant = 10
            extraInfoContainer.setNeedsLayout()
            UIView.animate(withDuration: 0.5,
                animations: {self.blurView!.alpha = 1; self.extraInfoContainer.layoutIfNeeded()},
                completion: {finished in UIView.animate(withDuration: 0.5, animations:{self.extraInfoLabel.alpha = 1})})
        }
        else {
            extraInfoContainerHeight.constant = 0
            extraInfoContainerPaddingTop.constant = 0
            extraInfoContainer.setNeedsLayout()
            UIView.animate(withDuration: 0.5,
                animations: {self.blurView!.alpha = 0; self.extraInfoLabel.alpha = 0;self.extraInfoContainer.layoutIfNeeded()},
                completion: {finished in self.blurView!.removeFromSuperview()})
        }
    }
    
    var poi:Poi?
    var destination:PoiView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let normalAttachment = NSTextAttachment()
        normalAttachment.image = UIImage(named: "down_arrow")
        let normalAttachmentString = NSAttributedString(attachment: normalAttachment)
        let normalString = NSMutableAttributedString(string: poi!.address + " ", attributes: [NSForegroundColorAttributeName: UIColor.white])
        normalString.append(normalAttachmentString)
        
        let selectedAttachment = NSTextAttachment()
        selectedAttachment.image = UIImage(named: "up_arrow")
        let selectedAttachmentString = NSAttributedString(attachment: selectedAttachment)
        let selectedString = NSMutableAttributedString(string: poi!.address + " ", attributes: [NSForegroundColorAttributeName: UIColor.white])
        selectedString.append(selectedAttachmentString)
        
        navigationTitleButton.setAttributedTitle(normalString, for: UIControlState())
        navigationTitleButton.setAttributedTitle(selectedString, for: UIControlState.selected)
        
        extraInfoLabel.text = ""
        if poi!.info != "" {
            extraInfoLabel.text = poi!.info + "\n\n"
        }
        if poi!.extraInfo != "" {
            extraInfoLabel.text = extraInfoLabel.text! + poi!.extraInfo
        }
        if extraInfoLabel.text == "" {
            extraInfoLabel.text = Util.noExtraInfo
        }
        
        
        // Valorizzo un pò di costanti
        positionInfo = Util.getCurrentPositionOrFakePosition() // Get current user position, if user is not in Rome I use a fake position (Rome center)
        navigationBarHeight = self.navigationController!.navigationBar.frame.size.height
        statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        constant_3 = Util.screenHeight() - statusBarHeight! - navigationBarHeight! - constant_2
        tapToCollapseGesture = UITapGestureRecognizer(target:self, action:#selector(DetailViewController.scrollUpContent))
        
        // Imposto la regione visibile della mappa
        let region = SKCoordinateRegion(center: positionInfo!.currentPosition, zoomLevel: 15)
        detailMapView.visibleRegion = region
        
        
        // --------------------------
        
        
        // 0. Faccio partire il loader
        loader.start()
        
        // 1. Calcolo il percoso per raggiungere il punto d'interesse
        showRoute()
        detailMapView.layoutIfNeeded()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Se sono a Roma aggiorno la posizione dell'utente di continuo
        if positionInfo!.isRealPosition {
            timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(DetailViewController.updateUserPosition), userInfo: nil, repeats: true)
        }
        else {
            let alertController = UIAlertController(title: Util.youAreNotHereTitle, message: Util.youAreNotHereMessage, preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: Util.youAreNotHereButtonText, style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        
        
        // 2. Mi salvo il livello di zoom e centro della mappa quando la mappa è grande
        centerWhenMapIsBig = detailMapView.visibleRegion.center
        zoomWhenMapIsBig = detailMapView.visibleRegion.zoomLevel
        
        // 3. Riduco l'altezza della view contenente la mappa, adesso è grande quanto screenHeight - detailViewHeight
        spaceBetweenBottomMap.constant = Util.screenHeight() - statusBarHeight! - navigationBarHeight! - constant_1!
        detailMapView.layoutIfNeeded()
        
        // 4. Centro nuovamente la mappa in base al percorso
        fitRoute()
        detailMapView.layoutIfNeeded()
        
        // 5. Aumento l'altezza della view contente la mappa, adesso alta quanto tutto lo schermo ma in parte coperta dalle info
        spaceBetweenBottomMap.constant = constant_2
        detailMapView.layoutIfNeeded()
    
        // 6. Calcolo il centro della mappa quando la mappa è piccola
        let newCenter = CGPoint(x: Util.screenWidth()/2, y: Util.screenHeight() - statusBarHeight! - navigationBarHeight! - constant_2 - (constant_1!/2))
        
        // 7. Mi salvo il livello di zoom e centro della mappa quando la mappa è piccola
        centerWhenMapIsSmall = detailMapView.coordinate(for: newCenter)
        zoomWhenMapIsSmall = detailMapView.visibleRegion.zoomLevel
        
        // 8. Sposto il centro della mappa in modo da mostrare il percorso nella parte visibile della view
        detailMapView.animate(toLocation: centerWhenMapIsSmall!, withDuration: 0)
        
        // 9. Aspetto un secondo e mezzo e rimuovo il loader
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
            self.removeLoader()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if timer != nil {
            timer!.invalidate()
        }
    }
    
    func showRoute() {
        SKRoutingService.sharedInstance().routingDelegate = self // set for receiving routing callbacks
        SKRoutingService.sharedInstance().mapView = detailMapView // use the map view instance for route rendering
        
        if poi != nil {
            
            destination = PoiView(poi: poi!)
            destination!.isSelected = false
            let animationSettings = SKAnimationSettings()
            detailMapView.addAnnotation(destination, with: animationSettings)
            let route = SKRouteSettings()
            
            route.startCoordinate = positionInfo!.currentPosition
            if !positionInfo!.isRealPosition {
                CustomPositionerService.sharedInstance().addRomeCenterAsUserPosition(detailMapView)
            }
            
            route.destinationCoordinate = destination!.location
            route.shouldBeRendered = true // If false, the route will not be rendered.
            route.routeMode = SKRouteMode.pedestrian
            route.maximumReturnedRoutes = 1
            route.routeRestrictions.avoidHighways = true
            SKRoutingService.sharedInstance().calculateRoute(route)
            
            fitRoute()
        }
    }
    
    func removeLoader() {
        loader.stop()
        UIView.animate(withDuration: 0.5,
            delay: 0.0,
            options: .curveLinear,
            animations: {self.loaderContainer.alpha = 0},
            completion: {finished in self.loaderContainer.removeFromSuperview()})
    }
    
    func fitRoute() {
        var boundingBox = SKBoundingBox()
        boundingBox.topLeftCoordinate = destination!.location
        boundingBox.bottomRightCoordinate = destination!.location
        boundingBox = boundingBox.includingLocation(positionInfo!.currentPosition)
        detailMapView.fitBounds(boundingBox, withPadding: CGSize(width: 25, height: 25))
        detailMapView.visibleRegion.zoomLevel = detailMapView.visibleRegion.zoomLevel - 0.2
        continueRotaring = false
    }
    
    func routingService(_ routingService: SKRoutingService!, didFinishRouteCalculationWithInfo routeInformation: SKRouteInformation!) {
        routingService.zoomToRoute(with: UIEdgeInsets.zero, duration: 500)
        routeAdvices = SKRoutingService.sharedInstance().routeAdviceList(with: SKDistanceFormat.metric) as? [SKRouteAdvice]
        if routeAdvices != nil {
            let secondsToDestination = Int(routeAdvices![0].timeToDestination)
            let hoursToDestination = Int(secondsToDestination / 3600)
            let minutesToDestination = Int(secondsToDestination - (hoursToDestination * 3600)) / 60
            timeToDestination.text = "\(hoursToDestination) h \(minutesToDestination) m"
            let now = Date()
            let dateToDestination = now.addingTimeInterval(Double(secondsToDestination))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            let dateString = dateFormatter.string(from: dateToDestination)
            distanceToDestination.text = "\(routeAdvices![0].distanceToDestination) m - \(dateString)"
            routingTableView.reloadData()
        }
    }
    
    @IBOutlet weak var backButton: UIBarButtonItem! {
        didSet {
            backButton.target = self
            backButton.action = #selector(DetailViewController.back(_:))
        }
    }
    
    func back(_ sender: UIBarButtonItem) {
        SKRoutingService.sharedInstance().routingDelegate = nil // set for receiving routing callbacks
        SKRoutingService.sharedInstance().mapView = nil // use the map view instance for route rendering
        if destination != nil {
            detailMapView.removeAnnotation(withID: destination!.identifier)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func setMapCenter(_ duration: Float) {
        let center = isMapBig ? centerWhenMapIsBig! : centerWhenMapIsSmall!
        let zoomLevel = isMapBig ? zoomWhenMapIsBig! : zoomWhenMapIsSmall!
            
        detailMapView.animate(toLocation: center, withDuration: duration)
        let delay = Double(duration) * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) {
            self.detailMapView.animate(toZoomLevel: zoomLevel)
        }
    }
    
    func mapView(_ mapView: SKMapView!, didDoubleTapAt coordinate: CLLocationCoordinate2D) {
        if !isMapBig {
            scrollDownContent()
        }
    }
    
    
    // MARK: - Scroll view
    
    func scrollDownContent() {
        isMapBig = true
        scrollView.backgroundColor = UIColor.white
        scrollView.frame.origin.y = scrollView.frame.origin.y - scrollView.contentOffset.y
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
                self.scrollView.frame.origin.y = Util.screenHeight() - self.navigationBarHeight! - self.navigationBarHeight! - self.constant_2
            }, completion: { _ in
                self.spaceBetweenTopDetail.constant = self.constant_3!
                self.setMapCenter(0.3)
                self.scrollView.addGestureRecognizer(self.tapToCollapseGesture!)
        })
    }
    
    func scrollUpContent() {
        isMapBig = false
        scrollView.removeGestureRecognizer(tapToCollapseGesture!)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
                self.scrollView.frame.origin.y = self.scrollView.frame.origin.y - (Util.screenHeight() - self.statusBarHeight! - self.navigationBarHeight! - self.constant_1!) + self.constant_2
                self.spaceBetweenTopDetail.constant = self.constant_1!
            }, completion: { _ in
                self.setMapCenter(0.3)
                self.scrollView.backgroundColor = UIColor.clear
        })
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if !isMapBig && scrollView.contentOffset.y < -50 {
            scrollDownContent()
        }
        else if isMapBig && scrollView.contentOffset.y > 5 {
            scrollUpContent()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isMapBig && scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) {
            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: scrollView.contentSize.height - scrollView.frame.size.height)
        }
    }
    
    
    func updateUserPosition() {
        _ = Util.getCurrentPositionOrFakePosition()
    }

    
    // MARK: - Table view
    
    @IBOutlet weak var timeToDestination: UILabel!
    @IBOutlet weak var distanceToDestination: UILabel!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if routeAdvices != nil {
            return routeAdvices!.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if routeAdvices != nil {
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellReuseIdentifier, for: indexPath) as! RoutingTableViewCell
            cell.routeAdvice = routeAdvices![indexPath.row]
            return cell
        }
        else {
            return UITableViewCell()
        }
    }
    
}






