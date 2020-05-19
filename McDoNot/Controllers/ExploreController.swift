//
//  ViewController.swift
//  McDoNot
//
//  Created by Roberto Scarpati on 14/02/2020.
//  Copyright © 2020 McDoNot. All rights reserved.
//

import CoreLocation
import Firebase
import MapKit
import UIKit


let testingLocations: [Place] = PlaceManager.shared.listRangePlaces
var testingShownLocation: [Place] = []

var tags = ["Wi-Fi", "Food", "Accessibility", "Plugs", "Parking", "Vending Machines", "Smoking Areas"]
var images = [#imageLiteral(resourceName: "Wi-fi"), #imageLiteral(resourceName: "Bar"), #imageLiteral(resourceName: "Accessibility"), #imageLiteral(resourceName: "Plugs"), #imageLiteral(resourceName: "Parking"), #imageLiteral(resourceName: "Vending_machine"), #imageLiteral(resourceName: "Smoking")]
let tagWidths: [CGFloat] = [100, 100, 150, 100, 110, 190, 170]

class ExploreController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    deinit {
        print("\(self) ExploreController has been deinitialized")
    }
    
    var imageAccessibility = UIImage(named: "Accessibility")
    var imageBar = UIImage(named: "Bar")
    var imageParking = UIImage(named: "Parking")
    var imagePlugs = UIImage(named: "Plugs")
    var imageSmoking = UIImage(named: "Smoking")
    var imageVendingM = UIImage(named: "Vending_machine")
    var imageWiFi = UIImage(named: "Wi-fi")

    var tagBools = [false, false, false, false, false, false, false] {
        didSet {
            mapView.removeAnnotations(mapView.annotations)
            testingShownLocation = filterPlacesList(places: testingLocations, accessibility: tagBools[2], foodSelling: tagBools[1], freeParking: tagBools[4], plug: tagBools[3], smokingArea: tagBools[6], vendingMachine: tagBools[5], wiFi: tagBools[0])
            mapView.addAnnotations(getAnnotationsFromPlaces(Places: testingShownLocation))
            placeCollection.reloadData()
        }
    }

    @IBOutlet var tagCollection: UICollectionView!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var placeCollection: UICollectionView!

    var userLocation = CLLocation()

    private var userTrackingButton: MKUserTrackingButton!
    private var scaleView: MKScaleView!

    private let locationManager = CLLocationManager()
    
    let db = Firestore.firestore()

    private func setupUserTrackingButtonAndScaleView() {
        mapView.showsCompass = false
        mapView.showsUserLocation = true

        userTrackingButton = MKUserTrackingButton(mapView: mapView)
        userTrackingButton.layer.backgroundColor = #colorLiteral(red: 0.9986192584, green: 0.80353266, blue: 0.5354811549, alpha: 1)
        userTrackingButton.tintColor = .white
        userTrackingButton.layer.borderColor = UIColor.white.cgColor
        userTrackingButton.layer.borderWidth = 1
        userTrackingButton.layer.cornerRadius = 5
        userTrackingButton.isHidden = false // Unhides when location authorization is given.
        view.addSubview(userTrackingButton)

        // By default, `MKScaleView` uses adaptive visibility, so it only displays when zooming the map.
        // This is behavior is confirgurable with the `scaleVisibility` property.
        scaleView = MKScaleView(mapView: mapView)
        scaleView.legendAlignment = .trailing
        view.addSubview(scaleView)

        let stackView = UIStackView(arrangedSubviews: [scaleView, userTrackingButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: self.mapView.trailingAnchor, constant: -10),
        ])
    }

    private func registerAnnotationViewClasses() {
        mapView.register(LibraryAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(OutdoorAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(CafeAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        //        mapView.register(ClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
    }

//        private func loadDataForMapRegionAndBikes() {
//            guard let plistURL = Bundle.main.url(forResource: "Data", withExtension: "plist") else {
//                fatalError("Failed to resolve URL for `Data.plist` in bundle.")
//            }
//
//            do {
//                let plistData = try Data(contentsOf: plistURL)
//                let decoder = PropertyListDecoder()
//                let decodedData = try decoder.decode(MapData.self, from: plistData)
//                mapView.region = decodedData.region
//                mapView.addAnnotations(decodedData.places)
//            } catch {
//                fatalError("Failed to load provided data, error: \(error.localizedDescription)")
//            }
//        }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == tagCollection {
            return tags.count
        } else {
            return testingShownLocation.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == tagCollection {
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

            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "placeCollectionCell", for: indexPath) as! PlaceCollectionCell
            
            cell.place = testingShownLocation[indexPath.row]
            let tempElement = testingShownLocation[indexPath.row]

            var tagVector: [Tag] = []

            setupTag(tagVector: &tagVector, place: tempElement)

            cell.placeLabel.text = tempElement.name
            cell.placeTag.text = tempElement.type.uppercased()
            
            cell.placeImage.image = UIImage(named: calculateImageName(name: cell.place!.name, type: cell.place!.type))
            cell.placeImage.contentMode = UIView.ContentMode.scaleAspectFill
            cell.tagList = tagVector
            
            if locationManager.location != nil {
                userLocation = CLLocation(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!)
                let addressCoord = CLLocation(latitude: tempElement.latitude, longitude: tempElement.longitude)
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


            cell.backgroundColor = UIColor(named: "LightGrey")

            cell.smallTagCollection.reloadData()
            
            cell.setupFavouriteButton()

            return cell
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let DetailController = segue.destination as? DetailPlaceController
        let indexPath = placeCollection.indexPathsForSelectedItems?.first

        DetailController?.placeLocationLon = testingShownLocation[indexPath!.row].longitude
        DetailController?.placeLocationLat = testingShownLocation[indexPath!.row].latitude
        DetailController?.placeNameText = testingShownLocation[indexPath!.row].name
        DetailController?.placeTypeText = testingShownLocation[indexPath!.row].type
        DetailController?.placeAddressText = testingShownLocation[indexPath!.row].address
        DetailController?.servicesList = [
            testingShownLocation[indexPath!.row].wiFi,
            testingShownLocation[indexPath!.row].accessibility,
            testingShownLocation[indexPath!.row].plug,
            testingShownLocation[indexPath!.row].foodSelling,
            testingShownLocation[indexPath!.row].freeParking,
            testingShownLocation[indexPath!.row].smokingArea,
            testingShownLocation[indexPath!.row].vendingMachine,
            testingShownLocation[indexPath!.row].isSilent]
        
        DetailController?.place = PlaceManager.shared.listRangePlaces[indexPath!.row]
        
        NotificationCenter.default.addObserver(self, selector: "updateObject", name: NSNotification.Name(rawValue: "udpateObject"), object: nil)
    }
    
    @objc func updateObject() {
        placeCollection.reloadData()
        for cell in placeCollection.visibleCells {
            (cell as! PlaceCollectionCell).setupFavouriteButton()
        }
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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == placeCollection {
            performSegue(withIdentifier: "collectionDetailSegue", sender: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        for cell in placeCollection.visibleCells {
            (cell as! PlaceCollectionCell).setupFavouriteButton()
        }
        placeCollection.reloadData()
    }

    var listFavouritePlaces: [Place] = []
    var listRangePlaces: [Place] = []
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 500
    var isDownloadComplete: Bool = false
    let id = UIDevice.current.identifierForVendor?.uuidString

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUserTrackingButtonAndScaleView()
        registerAnnotationViewClasses()

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        testingShownLocation = filterPlacesList(places: testingLocations, accessibility: tagBools[2], foodSelling: tagBools[1], freeParking: tagBools[4], plug: tagBools[3], smokingArea: tagBools[6], vendingMachine: tagBools[5], wiFi: tagBools[0])

        //        loadDataForMapRegionAndBikes()
        mapView.addAnnotations(getAnnotationsFromPlaces(Places: testingShownLocation))
        mapView.delegate = self

        tagCollection.dataSource = self
        tagCollection.delegate = self

        placeCollection.dataSource = self
        placeCollection.delegate = self

        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 200, longitudinalMeters: 200)
            mapView.setRegion(viewRegion, animated: true)
        }

        ConnectionManager.shared.checkForConnection { checkInternet in
            if checkInternet {
            } else {
            }
        }
    }

    func setupTag(tagVector: inout [Tag], place: Place) {
        tagVector.append(Tag(availability: place.wiFi, imageName: "Wi-fi", used: false))
        tagVector.append(Tag(availability: place.accessibility, imageName: "Accessibility", used: false))
        tagVector.append(Tag(availability: place.foodSelling, imageName: "Bar", used: false))
        tagVector.append(Tag(availability: place.freeParking, imageName: "Parking", used: false))
        tagVector.append(Tag(availability: place.plug, imageName: "Plugs", used: false))
        tagVector.append(Tag(availability: place.smokingArea, imageName: "Smoking", used: false))
        tagVector.append(Tag(availability: place.vendingMachine, imageName: "Vending_machine", used: false))
    }

    func getAnnotationsFromPlaces(Places: [Place]) -> [PlaceAnnotationModel] {
        var annotations: [PlaceAnnotationModel] = []
        for place in Places {
            annotations.append(PlaceAnnotationModel(place: place))
        }
        return annotations
    }
    
}

extension UIView {
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }

    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable
    var borderColor: UIColor? {
        get {
            let color = UIColor(cgColor: layer.borderColor!)
            return color
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }

    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = shadowRadius
        }
    }

    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        } set {
            layer.shadowOffset = newValue
        }
    }

    @IBInspectable
    var shadowColor: UIColor {
        get {
            return UIColor(cgColor: layer.shadowColor!)
        }
        set {
            layer.shadowColor = newValue.cgColor
        }
    }

    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
}

extension ExploreController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let cluster = annotation as? MKClusterAnnotation {
            let markerAnnotationView = MKMarkerAnnotationView()
            markerAnnotationView.glyphText = String(cluster.memberAnnotations.count)
            markerAnnotationView.markerTintColor = #colorLiteral(red: 0.6869741082, green: 0.7306327224, blue: 0.9675483108, alpha: 1)
            markerAnnotationView.canShowCallout = false
            markerAnnotationView.displayPriority = .required
            
            return markerAnnotationView
        }
        
        if let annotation = annotation as? PlaceAnnotationModel {
            
            switch annotation.type {
            case .library:
                return LibraryAnnotationView(annotation: annotation, reuseIdentifier: LibraryAnnotationView.ReuseID)
            case .cafe:
                return CafeAnnotationView(annotation: annotation, reuseIdentifier: CafeAnnotationView.ReuseID)
            case .outdoor:
                return OutdoorAnnotationView(annotation: annotation, reuseIdentifier: OutdoorAnnotationView.ReuseID)
            }
        }
        
        return nil
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation is MKUserLocation { return }
        if !(view.annotation is MKClusterAnnotation) {
            var index = Int()
            for i in 0 ..< testingShownLocation.count {
                if (view.annotation as! PlaceAnnotationModel).location!.ID == testingShownLocation[i].ID {
                    index = i
                }
            }
            
            
            
            let indexPath = IndexPath(row: index, section: 0)
            
            placeCollection.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        } else {
            var array = (view.annotation as! MKClusterAnnotation).memberAnnotations
            var maximumDistance: Double = 0
            for annotation in array {
                for annotation2 in array {
                    let location1 = CLLocation(latitude: (annotation2 as! PlaceAnnotationModel).location!.latitude, longitude: (annotation2 as! PlaceAnnotationModel).location!.longitude)
                    let location2 = CLLocation(latitude: (annotation as! PlaceAnnotationModel).location!.latitude, longitude: (annotation as! PlaceAnnotationModel).location!.longitude)
                    if maximumDistance < location1.distance(from: location2) {
                        maximumDistance = location1.distance(from: location2)
                    }
                }
            }
            
            mapView.setRegion(MKCoordinateRegion(center: array.first!.coordinate, latitudinalMeters: maximumDistance * 4, longitudinalMeters: maximumDistance), animated: true)
        }
        
    }
}

extension ExploreController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let locationAuthorized = status == .authorizedWhenInUse
        userTrackingButton.isHidden = !locationAuthorized
    }
}
