//
//  DetailPlaceController.swift
//  McDoNot
//
//  Created by Fabbio on 24/02/2020.
//  Copyright © 2020 McDoNot. All rights reserved.
//

import MapKit
import UIKit
import Firebase

class DetailPlaceController: UIViewController {
    
    deinit {
         print("\(self) DetailPlaceController has been deinitialized")
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "udpateObject"), object: nil)
     }
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var placeName: UILabel!
    @IBOutlet var placeType: UILabel!
    @IBOutlet var placeAddress: UILabel!

    @IBOutlet var wifiBool: UIView!
    @IBOutlet var accessibilityBool: UIView!
    @IBOutlet var plugsBool: UIView!
    @IBOutlet var foodBool: UIView!
    @IBOutlet var parkingBool: UIView!
    @IBOutlet var vendingBool: UIView!
    @IBOutlet var smokingBool: UIView!

    @IBOutlet var placeQuiet: UILabel!
    @IBOutlet weak var favouriteButton: UIButton!
    
    var placeNameText = ""
    var placeTypeText = ""
    var placeAddressText = ""
    var servicesList: [Bool] = []
    var mapClick = UIView()
    
    var place: Place?

    var placeLocationLon: Double = 0.0
    var placeLocationLat: Double = 0.0
    let regionRadius: CLLocationDistance = 1000
    let pin = MKPointAnnotation()
    
    
    @objc func checkAction(sender : UITapGestureRecognizer) {
//        let location = MKMapItem(placemark: MKPlacemark(coordinate: pin.coordinate))
//        location.name = pin.title
//        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
//        location.openInMaps(launchOptions: launchOptions)
    }
    
    @IBAction func openMap(_ sender: Any) {
        let location = MKMapItem(placemark: MKPlacemark(coordinate: pin.coordinate))
        location.name = pin.title
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.openInMaps(launchOptions: launchOptions)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        mapView.isUserInteractionEnabled = false
//        mapClick.frame = CGRect(x: mapView.frame.minX, y: mapView.frame.minY, width: mapView.frame.width, height: mapView.frame.height)
//        view.addSubview(mapClick)
//        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.checkAction))
//        mapClick.addGestureRecognizer(gesture)

        centerMapOnLocation(location: CLLocation(latitude: placeLocationLat, longitude: placeLocationLon))
        
        setupFavouriteButton()
        
        
        mapView.register(LibraryAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)

        placeName.text = placeNameText
        placeType.text = placeTypeText.uppercased()
        placeAddress.text = placeAddressText
        pin.title = placeNameText
        pin.coordinate = CLLocationCoordinate2D(latitude: placeLocationLat, longitude: placeLocationLon)
        mapView.addAnnotation(pin)

        for i in 0 ..< servicesList.count {
            if servicesList[i] == false {
                switch i {
                case 0:
                    wifiBool.alpha = 0.3
                case 1:
                    accessibilityBool.alpha = 0.3
                case 2:
                    plugsBool.alpha = 0.3
                case 3:
                    foodBool.alpha = 0.3
                case 4:
                    parkingBool.alpha = 0.3
                case 5:
                    smokingBool.alpha = 0.3
                case 6:
                    vendingBool.alpha = 0.3
                case 7:
                    placeQuiet.text = "This place generally isn't very quiet."
                default:
                    print("Error")
                }
            }
        }
    }
    
    
    
    func setupFavouriteButton() {
            if let myImage = UIImage(named: "Heart") {
                let tintableImage = myImage.withRenderingMode(.alwaysTemplate)
                favouriteButton.setImage(tintableImage, for: .normal)
            }
        
        favouriteButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 2, right: 0)
            
            var buffer = false

            for favPlace in PlaceManager.shared.listFavouritePlaces {
                if self.place?.ID == favPlace.ID {
                    buffer = true
                }
            }
            
            if buffer {
                self.favouriteButton.imageView?.tintColor = #colorLiteral(red: 1, green: 0.8039215686, blue: 0.5333333333, alpha: 1)
            } else {
                self.favouriteButton.imageView?.tintColor = #colorLiteral(red: 0.918313086, green: 0.918313086, blue: 0.918313086, alpha: 1)
            }
            

//            PlaceManager.shared.downloadFavPlace { test in
//                if !test {
//                    print("******ERROR******")
//                }
//
//                var buffer = false
//
//                for favPlace in PlaceManager.shared.listFavouritePlaces {
//                    if self.place?.ID == favPlace.ID {
//                        buffer = true
//                    }
//                }
//
//                if buffer {
//                    self.favouriteButton.imageView?.tintColor = #colorLiteral(red: 1, green: 0.8039215686, blue: 0.5333333333, alpha: 1)
//                } else {
//                    self.favouriteButton.imageView?.tintColor = #colorLiteral(red: 0.918313086, green: 0.918313086, blue: 0.918313086, alpha: 1)
//                }
//            }

            
        }

    override func viewDidAppear(_ animated: Bool) {
    }

    
    
    @IBAction func favouriteButtonTapped(_ sender: Any) {
        var buffer = false
        for favPlace in PlaceManager.shared.listFavouritePlaces {
            if place?.ID == favPlace.ID {
                buffer = true
            }
        }
        if !buffer {
            favouriteButton.hearbeatMod()
            favouriteButton.imageView?.tintColor = #colorLiteral(red: 1, green: 0.8039215686, blue: 0.5333333333, alpha: 1)

            DBManager.shared.addPlaceToFavourites(db: Firestore.firestore(), place: place!, userID: FirstLoginManager.shared.userID) { test in
                if test {
                    
                }
            }
            PlaceManager.shared.listFavouritePlaces.append(self.place!)
        } else {
            favouriteButton.imageView?.tintColor = #colorLiteral(red: 0.918313086, green: 0.918313086, blue: 0.918313086, alpha: 1)
            DBManager.shared.removePlaceFromFavourites(db: Firestore.firestore(), place: place!, userID: FirstLoginManager.shared.userID) { test in
                if test {
                    
                }
            }
            for i in 0 ..< PlaceManager.shared.listFavouritePlaces.count {
                if self.place!.ID == PlaceManager.shared.listFavouritePlaces[i].ID {
                    PlaceManager.shared.listFavouritePlaces.remove(at: i)
                    break
                }
            }
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "udpateObject"), object: nil)
    }

}

extension DetailPlaceController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return LibraryAnnotationView(annotation: annotation, reuseIdentifier: LibraryAnnotationView.ReuseID)
    }
}
