//
//  FavoritesController.swift
//  McDoNot
//
//  Created by Fabbio on 24/02/2020.
//  Copyright © 2020 McDoNot. All rights reserved.
//

import CoreLocation
import Foundation
import UIKit
import CoreLocation

class FavoritesController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    deinit {
         print("\(self) FavoriteController has been deinitialized")
     }
    
    var locationManager = CLLocationManager()
    var userLocation = CLLocation()
    var favoritesImg = UIImageView()
    var titleLabel : UILabel?
    var subtitleLabel : UILabel?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if PlaceManager.shared.listFavouritePlaces.count > 0{
            
            favoritesImg.alpha = 0
            titleLabel?.alpha = 0
            subtitleLabel?.alpha = 0
            
            
            return PlaceManager.shared.listFavouritePlaces.count
        }
        else{
            
            favoritesImg.alpha = 1
            titleLabel?.alpha = 1
            subtitleLabel?.alpha = 1
            favoritesImg = UIImageView(image: UIImage(named: "emptyFav"))
            favoritesImg.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
            favoritesImg.contentMode = .bottom
            
            tableView.backgroundView = favoritesImg
            
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = placesTable.dequeueReusableCell(withIdentifier: "PlacesCell") as! PlacesCell
        cell.place = PlaceManager.shared.listFavouritePlaces[indexPath.row]
        let tempElement = PlaceManager.shared.listFavouritePlaces[indexPath.row]

        var tagVector: [Tag] = []
        setupTag(tagVector: &tagVector, place: tempElement)
        cell.tagList = tagVector
        if locationManager.location != nil {
            userLocation = CLLocation(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!)
            let addressCoord = CLLocation(latitude: tempElement.latitude, longitude: tempElement.longitude)
            let distance = userLocation.distance(from: addressCoord)
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 1
            formatter.maximumFractionDigits = 1
            cell.placeDistance.text = formatter.string(from: NSNumber(value: distance/1000))! + " " + "km"
        }
        else{
            cell.placeDistance.text = ""
        }
        
        
        

        cell.placeLabel.text = tempElement.name
        cell.placeTag.text = tempElement.type.uppercased()
        
       
        cell.placeImage.image = UIImage(named: calculateImageName(name: cell.place!.name, type: cell.place!.type))
        cell.placeImage.contentMode = UIView.ContentMode.scaleAspectFill

        

        cell.selectionStyle = UITableViewCell.SelectionStyle.none

        cell.backgroundColor = UIColor(named: "LightGrey")
        
        
        
        cell.setupFavouriteButton()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180.0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as! PlacesCell).smallTagCollection.reloadData()
        
//        let tempElement = PlaceManager.shared.listFavouritePlaces[indexPath.row]
//
//        let addressCoord = CLLocation(latitude: tempElement.latitude, longitude: tempElement.longitude)
//        let distance = userLocation.distance(from: addressCoord)
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .decimal
//        formatter.minimumFractionDigits = 1
//        formatter.maximumFractionDigits = 1
//        (cell as! PlacesCell).placeDistance.text = formatter.string(from: NSNumber(value: distance/1000))! + " " + "km"
//        (cell as! PlacesCell).placeImage.loadImage(fromURL: tempElement.imageURL)
//        (cell as! PlacesCell).placeImage.contentMode = UIView.ContentMode.scaleAspectFill
//
//        (cell as! PlacesCell).place = PlaceManager.shared.listFavouritePlaces[indexPath.row]
//
//        (cell as! PlacesCell).selectionStyle = UITableViewCell.SelectionStyle.none
//
//        (cell as! PlacesCell).backgroundColor = UIColor(named: "LightGrey")
//
//        (cell as! PlacesCell).placeTag.addConstraint(.init(item: (cell as! PlacesCell).placeTag!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: (cell as! PlacesCell).placeTag.intrinsicContentSize.width+12))
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "favoriteDetailSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let DetailController = segue.destination as? DetailPlaceController
        let indexPath = placesTable.indexPathForSelectedRow
        DetailController?.placeLocationLon = PlaceManager.shared.listFavouritePlaces[indexPath!.row].longitude
        DetailController?.placeLocationLat = PlaceManager.shared.listFavouritePlaces[indexPath!.row].latitude
        DetailController?.placeNameText = PlaceManager.shared.listFavouritePlaces[indexPath!.row].name
        DetailController?.placeTypeText = PlaceManager.shared.listFavouritePlaces[indexPath!.row].type
        DetailController?.placeAddressText = PlaceManager.shared.listFavouritePlaces[indexPath!.row].address
        DetailController?.servicesList = [
            PlaceManager.shared.listFavouritePlaces[indexPath!.row].wiFi,
            PlaceManager.shared.listFavouritePlaces[indexPath!.row].accessibility,
            PlaceManager.shared.listFavouritePlaces[indexPath!.row].plug,
            PlaceManager.shared.listFavouritePlaces[indexPath!.row].foodSelling,
            PlaceManager.shared.listFavouritePlaces[indexPath!.row].freeParking,
            PlaceManager.shared.listFavouritePlaces[indexPath!.row].smokingArea,
            PlaceManager.shared.listFavouritePlaces[indexPath!.row].vendingMachine,
            PlaceManager.shared.listFavouritePlaces[indexPath!.row].isSilent]
        
        DetailController?.place = PlaceManager.shared.listFavouritePlaces[indexPath!.row]
        
        NotificationCenter.default.addObserver(self, selector: "updateObject", name: NSNotification.Name(rawValue: "udpateObject"), object: nil)
    }
    
    @objc func updateObject() {
        placesTable.reloadData()
        for cell in placesTable.visibleCells {
            (cell as! PlacesCell).setupFavouriteButton()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let w = UIScreen.main.bounds.width
        let h = UIScreen.main.bounds.height
        
        titleLabel = UILabel(frame: CGRect(x: w / 2, y: h / 2, width: 200, height: 30))
        titleLabel?.textAlignment = .center
        titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 18.0)
        titleLabel?.textColor = #colorLiteral(red: 0.2352941176, green: 0.2274509804, blue: 0.4470588235, alpha: 1)
        titleLabel?.numberOfLines = 0
        titleLabel?.text = "No places yet."
        titleLabel?.lineBreakMode = .byTruncatingTail
        titleLabel?.center = CGPoint(x: w / 2, y: h / 3 - 70)
        view.addSubview(titleLabel!)
        
        subtitleLabel = UILabel(frame: CGRect(x: w / 2, y: h / 2, width: 200, height: 100))
        subtitleLabel?.textAlignment = .center
        subtitleLabel?.font = UIFont(name: "Montserrat", size: 16.0)
        subtitleLabel?.textColor = #colorLiteral(red: 0.2352941176, green: 0.2274509804, blue: 0.4470588235, alpha: 1)
        subtitleLabel?.numberOfLines = 2
        subtitleLabel?.text = "Save and keep your favorite places"
        subtitleLabel?.lineBreakMode = .byTruncatingTail
        subtitleLabel?.center = CGPoint(x: w / 2, y: h / 3 - 30)
        view.addSubview(subtitleLabel!)

        placesTable.dataSource = self
        placesTable.delegate = self
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        placesTable.separatorStyle = UITableViewCell.SeparatorStyle.none
        
//        PlaceManager.shared.downloadFavPlace { (test) in
//            
//        }
//        
        placesTable.contentInset.bottom = (tabBarController?.tabBar.frame.height)!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        PlaceManager.shared.downloadFavPlace { (test) in
//
//        }
        
        placesTable.reloadData()
//        if PlaceManager.shared.listFavouritePlaces.count == 0 {
//            favoritesImg.alpha = 1
//            titleLabel?.alpha = 1
//            subtitleLabel?.alpha = 1
//            favoritesImg = UIImageView(image: UIImage(named: "emptyFav"))
//            favoritesImg.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
//            favoritesImg.contentMode = .bottom
//            
//            self.view.addSubview(favoritesImg)
//        } else {
//            favoritesImg.alpha = 0
//            titleLabel?.alpha = 0
//            subtitleLabel?.alpha = 0
//        }
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

    @IBOutlet weak var placesTable: UITableView!
    
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            if locationManager.location != nil {
                PlaceManager.shared.downloadFavPlace{ test in
                    if !test {
                        print("******ERROR******")
                    }
                    
                    
                    self.placesTable.reloadData()
                }
            }
        }
        
        if status == .notDetermined {
            configureLocationServices()
        }
        
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
    
    
    
    
    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}
