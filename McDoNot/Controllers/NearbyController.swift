//
//  ViewController.swift
//  McDoNot
//
//  Created by Roberto Scarpati on 14/02/2020.
//  Copyright © 2020 McDoNot. All rights reserved.
//

import CoreLocation
import Firebase
import Lottie
import MapKit
import UIKit

class NearbyController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UITextFieldDelegate,UICollectionViewDelegateFlowLayout {

    deinit {
        print("\(self) NearbyController has been deinitialized")
    }
    
    //    MARK: -OUTLETS

    @IBOutlet var tableTitleLabel: UILabel!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet var tagCollection: UICollectionView!
    @IBOutlet var placesTable: UITableView!

//    MARK: -ANIMATION VARIABLES

    var displayLink: CADisplayLink?
    let animationView = AnimationView()
    let blankView = UIView()
    let localPositionButton = UIButton(type: .custom)
    var nearbyImg = UIImageView()

//    MARK: -SETUP VARIABLES

    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let db = Firestore.firestore()
    var userLocation = CLLocation()

//    MARK: -CLASS VARIABLES

    var filteredPlaces: [Place] = []
    var isSearching = false
    var isFiltering = false

    
    let testingLocations: [Place] = PlaceManager.shared.listRangePlaces
    var testingShownLocation: [Place] = []

    var tags = ["Wi-Fi", "Food", "Accessibility", "Plugs", "Parking", "Vending Machines", "Smoking Areas"]
    var images = [#imageLiteral(resourceName: "Wi-fi"), #imageLiteral(resourceName: "Bar"), #imageLiteral(resourceName: "Accessibility"), #imageLiteral(resourceName: "Plugs"), #imageLiteral(resourceName: "Parking"), #imageLiteral(resourceName: "Vending_machine"), #imageLiteral(resourceName: "Smoking")]
    let tagWidths: [CGFloat] = [100, 100, 150, 100, 110, 190, 170]
    
    
    
//    MARK: -TAG VARIABLES

    var tagBools = [false, false, false, false, false, false, false] {
        didSet {
            isFiltering = tagBools == [false, false, false, false, false, false, false] ? false : true
            filteredPlaces = filterPlacesList(places: PlaceManager.shared.listRangePlaces, accessibility: tagBools[2], foodSelling: tagBools[1], freeParking: tagBools[4], plug: tagBools[3], smokingArea: tagBools[6], vendingMachine: tagBools[5], wiFi: tagBools[0])
            view.endEditing(true)
            placesTable.reloadData()
            
            if filteredPlaces.count == 0 {
                self.tableTitleLabel.text = "No results"
            }
            else{
                self.tableTitleLabel.text = "Near to you"
            }
            
            if isFiltering == false{
                             if CLLocationManager.locationServicesEnabled(){
                              
                              switch CLLocationManager.authorizationStatus() {
                              case .notDetermined, .restricted, .denied:
                                 tableTitleLabel.text = "No places near to you"
                                 self.placesTable.isHidden = true
                                 self.nearbyImg.isHidden = false
                                 
                                  break
                                  
                              case .authorizedAlways, .authorizedWhenInUse:
                                  tableTitleLabel.text = "Near to you"
                                  break

                              @unknown default:
                                  print("error")
                              }
                          }
            }
            
            
        }
    }
    
    // MARK: - CLASS VARIABLES FOR AUTOCOMPLETION
    
    var searchedSpot = Place(accessibility: false, address: "", foodSelling: false, freeParking: false, ID: "", imageURL: "", isSilent: false, latitude: 0, longitude: 0, name: "", plug: false, rating: 0, ratingCount: 0, smokingArea: false, type: "", vendingMachine: false, wiFi: false)
    var placemark: MKPlacemark?
    
    // MARK: - TABLEVIEW DELEGATE & DATA SOURCE

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering{
            return filteredPlaces.count
        } else {
            return PlaceManager.shared.listRangePlaces.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = placesTable.dequeueReusableCell(withIdentifier: "PlacesCell") as! PlacesCell
        
        if isFiltering{
            cell.place = filteredPlaces[indexPath.row]
            let tempElementSearched = filteredPlaces[indexPath.row]

            var tagVector: [Tag] = []

            setupTag(tagVector: &tagVector, place: tempElementSearched)

            cell.placeLabel.text = tempElementSearched.name
            cell.placeTag.text = tempElementSearched.type.uppercased()
            cell.tagList = tagVector
            if locationManager.location != nil {
                userLocation = CLLocation(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!)
                let addressCoord = CLLocation(latitude: tempElementSearched.latitude, longitude: tempElementSearched.longitude)
                let distance = userLocation.distance(from: addressCoord)
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.minimumFractionDigits = 1
                formatter.maximumFractionDigits = 1
                cell.placeDistance.text = formatter.string(from: NSNumber(value: distance / 1000))! + " " + "km"
            }
            else{
                cell.placeDistance.text = ""
            }
            
            cell.placeImage.image = UIImage(named: calculateImageName(name: cell.place!.name, type: cell.place!.type))
            cell.placeImage.contentMode = UIView.ContentMode.scaleAspectFill
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none

            cell.backgroundColor = UIColor(named: "LightGrey")
        }
        else {
            let tempElement = PlaceManager.shared.listRangePlaces[indexPath.row]
            cell.place = PlaceManager.shared.listRangePlaces[indexPath.row]

            var tagVector: [Tag] = []

            setupTag(tagVector: &tagVector, place: tempElement)

            cell.placeLabel.text = tempElement.name
            cell.placeTag.text = tempElement.type.uppercased()
            cell.tagList = tagVector
            if locationManager.location != nil{
                userLocation = CLLocation(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!)
                let addressCoord = CLLocation(latitude: tempElement.latitude, longitude: tempElement.longitude)
                let distance = userLocation.distance(from: addressCoord)
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.minimumFractionDigits = 1
                formatter.maximumFractionDigits = 1
                cell.placeDistance.text = formatter.string(from: NSNumber(value: distance / 1000))! + " km"
            }
                
            else{
                cell.placeDistance.text = ""
            }
            
            cell.placeImage.image = UIImage(named: calculateImageName(name: cell.place!.name, type: cell.place!.type))
            cell.placeImage.contentMode = UIView.ContentMode.scaleAspectFill

            cell.selectionStyle = UITableViewCell.SelectionStyle.none

            cell.backgroundColor = UIColor(named: "LightGrey")
        }

        cell.setupFavouriteButton()

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "detailSegue", sender: self)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as! PlacesCell).smallTagCollection.reloadData()
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180.0
    }

    // MARK: - COLLECTIONVIEW DELEGATE, DATA SOURCE & FLOW LAYOUT

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView === tagCollection ? tags.count : tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagLabelsCell", for: indexPath) as! TagLabelsCell
        
        cell.btnTag.setTitle(tags[indexPath.row], for: .normal)
        cell.btnTag.setImage(images[indexPath.row].withTintColor(.lightGray), for: .normal)
        cell.btnTag.setTitleColor(.lightGray, for: .normal)
        cell.btnTag.frame.size = CGSize(width: cell.frame.size.width - 10, height: cell.btnTag.frame.size.height)
        
        if tagBools[indexPath.row] {
            cell.btnTag.backgroundColor = #colorLiteral(red: 0.6774679422, green: 0.7304675579, blue: 0.9886408448, alpha: 1)
            cell.btnTag.setTitleColor(.white, for: .normal)
            cell.btnTag.setImage(cell.btnTag.imageView?.image?.withTintColor(.white), for: .normal)
        } else {
            cell.btnTag.backgroundColor = #colorLiteral(red: 0.8901180029, green: 0.8902462125, blue: 0.8900898695, alpha: 1)
            cell.btnTag.setTitleColor(.lightGray, for: .normal)
            cell.btnTag.setImage(cell.btnTag.imageView?.image?.withTintColor(.lightGray), for: .normal)
        }
        
        if isSearching {
            cell.btnTag.isEnabled = false
            cell.btnTag.alpha = 0.5
        } else {
            cell.btnTag.isEnabled = true
            cell.btnTag.alpha = 1
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Compute the dimension of a cell for an NxN layout with space S between
        // cells.  Take the collection view's width, subtract (N-1)*S points for
        // the spaces between the cells, and then divide by N to find the final
        // dimension for the cell's width and height.
        
        if collectionView == tagCollection {
            return CGSize(width: tagWidths[indexPath.row], height: 50)
            
        } else {
            return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == tagCollection {
            return 0
        }
        return 0
    }
    
    
    //    MARK: - VIEWCONTROLLER
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FirstLoginManager.shared.loginProcedure(db: db)
        
        configureAnimation()
        
        configureDelegateDatasource()
        
        configurePlacesTable()
        
        configureTextField()
        
        configureLocationServices()
        
        locationManager(locationManager, didChangeAuthorization: authorizationStatus)
        
        configurePlaceManager()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        placesTable.reloadData()
        for cell in placesTable.visibleCells {
            (cell as! PlacesCell).setupFavouriteButton()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animationView.play(fromProgress: 0,
                           toProgress: 1,
                           loopMode: LottieLoopMode.playOnce,
                           completion: { finished in
                            if finished {
                                self.tabBarController?.tabBar.isHidden = false
                                self.animationView.removeFromSuperview()
                                self.blankView.removeFromSuperview()
                                
                                if PlaceManager.shared.listRangePlaces.count == 0 {
                                    self.nearbyImg.alpha = 1
                                    self.tableTitleLabel.text = "No places near to you"
                                    self.nearbyImg = UIImageView(image: UIImage(named: "emptyNear"))
                                    self.nearbyImg.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
                                    self.nearbyImg.contentMode = .bottom
                                    
                                    self.view.addSubview(self.nearbyImg)
                                } else {
                                    self.nearbyImg.alpha = 0
                                    self.tableTitleLabel.text = "Near to you"
                                }
                            } else {
                            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        // Dispose of any resources that can be recreated.
    }

//    MARK: - SEGUE

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let DetailController = segue.destination as? DetailPlaceController
        let indexPath = placesTable.indexPathForSelectedRow

        if !isSearching && !isFiltering {
            DetailController?.placeLocationLon = PlaceManager.shared.listRangePlaces[indexPath!.row].longitude
            DetailController?.placeLocationLat = PlaceManager.shared.listRangePlaces[indexPath!.row].latitude
            DetailController?.placeNameText = PlaceManager.shared.listRangePlaces[indexPath!.row].name
            DetailController?.placeTypeText = PlaceManager.shared.listRangePlaces[indexPath!.row].type
            DetailController?.placeAddressText = PlaceManager.shared.listRangePlaces[indexPath!.row].address
            DetailController?.servicesList = [
                PlaceManager.shared.listRangePlaces[indexPath!.row].wiFi,
                PlaceManager.shared.listRangePlaces[indexPath!.row].accessibility,
                PlaceManager.shared.listRangePlaces[indexPath!.row].plug,
                PlaceManager.shared.listRangePlaces[indexPath!.row].foodSelling,
                PlaceManager.shared.listRangePlaces[indexPath!.row].freeParking,
                PlaceManager.shared.listRangePlaces[indexPath!.row].smokingArea,
                PlaceManager.shared.listRangePlaces[indexPath!.row].vendingMachine,
                PlaceManager.shared.listRangePlaces[indexPath!.row].isSilent]
            DetailController?.place = PlaceManager.shared.listRangePlaces[indexPath!.row]
        } else if isFiltering && !isSearching {
            DetailController?.placeLocationLon = filteredPlaces[indexPath!.row].longitude
            DetailController?.placeLocationLat = filteredPlaces[indexPath!.row].latitude
            DetailController?.placeNameText = filteredPlaces[indexPath!.row].name
            DetailController?.placeTypeText = filteredPlaces[indexPath!.row].type
            DetailController?.placeAddressText = filteredPlaces[indexPath!.row].address
            DetailController?.servicesList = [
                filteredPlaces[indexPath!.row].wiFi,
                filteredPlaces[indexPath!.row].accessibility,
                filteredPlaces[indexPath!.row].plug,
                filteredPlaces[indexPath!.row].foodSelling,
                filteredPlaces[indexPath!.row].freeParking,
                filteredPlaces[indexPath!.row].smokingArea,
                filteredPlaces[indexPath!.row].vendingMachine,
                filteredPlaces[indexPath!.row].isSilent]
            DetailController?.place = filteredPlaces[indexPath!.row]
        } else {
            DetailController?.placeLocationLon = filteredPlaces[indexPath!.row].longitude
            DetailController?.placeLocationLat = filteredPlaces[indexPath!.row].latitude
            DetailController?.placeNameText = filteredPlaces[indexPath!.row].name
            DetailController?.placeTypeText = filteredPlaces[indexPath!.row].type
            DetailController?.placeAddressText = filteredPlaces[indexPath!.row].address
            DetailController?.servicesList = [
                filteredPlaces[indexPath!.row].wiFi,
                filteredPlaces[indexPath!.row].accessibility,
                filteredPlaces[indexPath!.row].plug,
                filteredPlaces[indexPath!.row].foodSelling,
                filteredPlaces[indexPath!.row].freeParking,
                filteredPlaces[indexPath!.row].smokingArea,
                filteredPlaces[indexPath!.row].vendingMachine,
                filteredPlaces[indexPath!.row].isSilent]
            DetailController?.place = filteredPlaces[indexPath!.row]
        }

        

        NotificationCenter.default.addObserver(self, selector: "updateObject", name: NSNotification.Name(rawValue: "udpateObject"), object: nil)
    }

    @objc func updateObject() {
        placesTable.reloadData()
        for cell in placesTable.visibleCells {
            (cell as! PlacesCell).setupFavouriteButton()
        }
        
    }

    @objc func animationCallback() {
        if animationView.isAnimationPlaying {
        }
    }

//    MARK: - TEXTFIELD DELEGATE

    
    @IBAction func searchPlace(_ sender: Any) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateObject(_:)), name: NSNotification.Name(rawValue: "gettingObject"), object: nil)
        
        performSegue(withIdentifier: "searchPlace", sender: self)
    }

    
    @objc func updateObject(_ notification: Notification) {
        if let tempMapitem = notification.userInfo?["place"] as? MKMapItem {
            let tempPlacemark = tempMapitem.placemark
            self.placemark = tempPlacemark
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "gettingObject"), object: nil)
            searchedSpot.address = tempPlacemark.title!
            searchedSpot.latitude = tempPlacemark.coordinate.latitude
            searchedSpot.longitude = tempPlacemark.coordinate.longitude
            searchField.text = searchedSpot.address
            localPositionButton.setImage(UIImage(named: "Position_outline"), for: .normal)
            
            self.isFiltering = false
            self.tagBools = [false, false, false, false, false, false, false]
            
            self.tagCollection.reloadData()
            
            PlaceManager.shared.downloadRangePlace(offsetRadiusKm: 25, location: CLLocation(latitude: searchedSpot.latitude, longitude: searchedSpot.longitude)) { (isComplete) in
                self.placesTable.reloadData()
            }
         }
        
        
        
    }

//    MARK: - LOCATIONMANAGER DELEGATE

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            self.nearbyImg.isHidden = true
            if locationManager.location != nil {
                PlaceManager.shared.downloadRangePlace(offsetRadiusKm: 25, location: locationManager.location!) { test in
                    
                    if !test {
                        print("******ERROR******")
                    }

                    self.placesTable.isHidden = false
                    
                    if self.isFiltering{
                        if self.filteredPlaces.count == 0{
                             self.tableTitleLabel.text = "No results"
                        }
                        else{
                            self.tableTitleLabel.text = "Near to you"
                        }
                        
                    }
                    
                    else{
                        self.tableTitleLabel.text = "Near to you"
                    }
                    
                    
                    self.placesTable.reloadData()
                }
            }
        }

        if status == .notDetermined {
            configureLocationServices()
        }
        
        if status == .denied{
            
            if self.isFiltering{
                if self.filteredPlaces.count == 0{
                    self.tableTitleLabel.text = "No results"
                }
                else{
                    self.tableTitleLabel.text = "Near to you"
                }
                
            }
                
            else{
                self.tableTitleLabel.text = "No places near to you"
                self.placesTable.isHidden = true
                self.nearbyImg.isHidden = false
            }
            
        }
    }

//    MARK: - SETUP FUNCTIONS

    func setupTag(tagVector: inout [Tag], place: Place) {
        tagVector.append(Tag(availability: place.wiFi, imageName: "Wi-fi", used: false))
        tagVector.append(Tag(availability: place.accessibility, imageName: "Accessibility", used: false))
        tagVector.append(Tag(availability: place.foodSelling, imageName: "Bar", used: false))
        tagVector.append(Tag(availability: place.freeParking, imageName: "Parking", used: false))
        tagVector.append(Tag(availability: place.plug, imageName: "Plugs", used: false))
        tagVector.append(Tag(availability: place.smokingArea, imageName: "Smoking", used: false))
        tagVector.append(Tag(availability: place.vendingMachine, imageName: "Vending_machine", used: false))
    }

    func configureLocationServices() {
        // Ask for Authorisation from the User.
        locationManager.requestAlwaysAuthorization()

        // For use in foreground
        locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }

    func configurePlaceManager() {
        
        if locationManager.location != nil {
            PlaceManager.shared.downloadRangePlace(offsetRadiusKm: 25, location: locationManager.location!) { _ in
                
                self.placesTable.reloadData()
            }
        }

        PlaceManager.shared.downloadFavPlace { test in
            self.placesTable.reloadData()
        }
    }

    func configureKeyboard() {
        placesTable.keyboardDismissMode = .onDrag
    }
    
    func configureAnimation(){
        let screenSize = UIScreen.main.bounds
        blankView.frame = screenSize
        blankView.backgroundColor = UIColor(named: "LightGrey")
        tabBarController?.tabBar.isHidden = true
        view.addSubview(blankView)

        let animation = Animation.named("Animation")
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        view.addSubview(animationView)

        animationView.backgroundBehavior = .pauseAndRestore
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true

        animationView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -12).isActive = true
        animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        animationView.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)

        /// Create a display link to make slider track with animation progress.
        displayLink = CADisplayLink(target: self, selector: #selector(animationCallback))
        displayLink?.add(to: .current,
                         forMode: RunLoop.Mode.default)
    }
    
    func configureDelegateDatasource(){
        tagCollection.dataSource = self
        tagCollection.delegate = self
        placesTable.dataSource = self
        placesTable.delegate = self
        
        locationManager.delegate = self
        
        searchField.delegate = self
    }
    
    func configurePlacesTable(){
        placesTable.separatorStyle = UITableViewCell.SeparatorStyle.none
        placesTable.contentInset.bottom = (tabBarController?.tabBar.frame.height)!
    }
    
    func configureTextField(){
        localPositionButton.setImage(UIImage(named: "Position_outline"), for: .normal)
        localPositionButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        localPositionButton.frame = CGRect(x: CGFloat(searchField.frame.size.width - 15), y: CGFloat(0), width: CGFloat(15), height: CGFloat(15))
        localPositionButton.addTarget(self, action: #selector(actualLocationRequested), for: .touchUpInside)
        searchField.rightView = localPositionButton
        searchField.rightViewMode = .always
    }
    

    
    @objc func actualLocationRequested(){
        if CLLocationManager.locationServicesEnabled(){
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                configureLocationServices()
                break
            case .authorizedAlways, .authorizedWhenInUse:
                if locationManager.location != nil{
                    localPositionButton.setImage(UIImage(named: "Position_filled"), for: .normal)
                    searchField.text = "Your position"
                    
                    PlaceManager.shared.downloadRangePlace(offsetRadiusKm: 25, location: locationManager.location!) { (downloadDone) in
                        if downloadDone{
                            //MARK: - FOR DAVID: WE HAVE TO RESET FILTERS HERE, AND EVEN WHEN YOU START SEARCH
                            self.isFiltering = false
                            self.tagBools = [false, false, false, false, false, false, false]
                            
                            self.tagCollection.reloadData()
                            self.placesTable.reloadData()
                        }
                    }
                }
            default:
                print("Error")
            }
        }
    }
    
 
}

