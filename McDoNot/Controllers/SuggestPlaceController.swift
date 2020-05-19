//
//  FavoritesController.swift
//  McDoNot
//
//  Created by Fabbio on 24/02/2020.
//  Copyright © 2020 McDoNot. All rights reserved.
//

import CoreLocation
import Firebase
import Foundation
import UIKit
import MapKit

class SuggestPlaceController: UIViewController, CLLocationManagerDelegate {
    
    deinit {
        print("\(self) SuggestPlaceController has been deinitialized")
    }
    
    var currentLocation: CLLocation = CLLocation()
    var locationName: String = ""
    var searchRadius: Int = 100
    let db = Firestore.firestore()
    var suggestedSpot = SuggestedPlace(accessibility: 0, address: "", foodSelling: 0, freeParking: 0, ID: "", imageURL: "", isSilent: 0, latitude: 0, longitude: 0, name: "", plug: 0, smokingArea: 0, suggestionCount: 0, type: "", vendingMachine: 0, wiFi: 0)
    var locationManager = CLLocationManager()
    var placemark: MKPlacemark?

    @IBOutlet var textField: UITextField!
    @IBOutlet var isSilent: UISwitch!
    @IBOutlet var wiFi: UISwitch!
    @IBOutlet var accessibility: UISwitch!
    @IBOutlet var plugs: UISwitch!
    @IBOutlet var foodSelling: UISwitch!
    @IBOutlet var parking: UISwitch!
    @IBOutlet var smokingArea: UISwitch!
    @IBOutlet var vendingMachine: UISwitch!

   var placesSearchController = SearchViewController()
    
    @IBAction func searchAddr(_ sender: Any) {
        if locationManager.location != nil {
            present(placesSearchController, animated: true, completion: {
                NotificationCenter.default.addObserver(self, selector: #selector(self.updateObject(_:)), name: NSNotification.Name(rawValue: "gettingObject"), object: nil)
            })
        } else {
            let alert = UIAlertController(title: "Position access request", message: "Please, give us the access to your position in order to retrieve your nearest places.", preferredStyle: UIAlertController.Style.alert)

            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))

            present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func updateObject(_ notification: Notification) {
        if let tempMapitem = notification.userInfo?["place"] as? MKMapItem {
            let tempPlacemark = tempMapitem.placemark
            self.placemark = tempPlacemark
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "gettingObject"), object: nil)
            textField.text = tempPlacemark.name
            suggestedSpot.name = tempPlacemark.name!
            suggestedSpot.address = tempPlacemark.title!
            suggestedSpot.latitude = tempPlacemark.coordinate.latitude
            suggestedSpot.longitude = tempPlacemark.coordinate.longitude
            suggestedSpot.type = translateTypeOfPlace(type: tempMapitem.pointOfInterestCategory)
            suggestedSpot.ID = suggestedSpot.name + suggestedSpot.address
         }
    }

    @IBAction func insertion(_ sender: Any) {
        if textField.text == "" {
            let alert = UIAlertController(title: "Empty text", message: "Please, insert a valid place.", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            
            present(alert, animated: true, completion: nil)
        } else {
            let accessibilityCounter = Int(truncating: NSNumber(value: accessibility.isOn))
            let foodSellingCounter = Int(truncating: NSNumber(value: foodSelling.isOn))
            let freeParkingCounter = Int(truncating: NSNumber(value: parking.isOn))
            let isSilentCounter = Int(truncating: NSNumber(value: isSilent.isOn))
            let plugsCounter = Int(truncating: NSNumber(value: plugs.isOn))
            let smokingAreaCounter = Int(truncating: NSNumber(value: smokingArea.isOn))
            let vendingMachineCounter = Int(truncating: NSNumber(value: vendingMachine.isOn))
            let wiFiCounter = Int(truncating: NSNumber(value: wiFi.isOn))
            
            if suggestedSpot.imageURL == "" {
                suggestedSpot.imageURL = "placeholder"
            }
            
            let insertionPlace = SuggestedPlace(accessibility: accessibilityCounter, address: placemark?.title ?? "address", foodSelling: foodSellingCounter, freeParking: freeParkingCounter, ID: suggestedSpot.ID, imageURL: suggestedSpot.imageURL, isSilent: isSilentCounter, latitude: suggestedSpot.latitude, longitude: suggestedSpot.longitude, name: suggestedSpot.name, plug: plugsCounter, smokingArea: smokingAreaCounter, suggestionCount: 1, type: suggestedSpot.type, vendingMachine: vendingMachineCounter, wiFi: wiFiCounter)
            
            DBManager.shared.updateCountSuggestion(db: db, place: insertionPlace) { insertionInfo in
                
                print(insertionInfo.placeAlreadyPresent)
                
                //Here you check if this place is already present in Places.
                if insertionInfo.placeAlreadyPresent{
                    let alert = UIAlertController(title: "Oh, it's already there!", message: "Seems like this place is already in our database, but thanks anyway.", preferredStyle: UIAlertController.Style.alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (action) in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    //Here you check if this place is already present as a Suggested Place.
                    if !insertionInfo.suggestionJustInserted{
                        let alert = UIAlertController(title: "Great suggestion!", message: "Thanks for your effort, we will review and insert the place as soon as possible.", preferredStyle: UIAlertController.Style.alert)
                        
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (action) in
                            self.dismiss(animated: true, completion: nil)
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                        
                    //If the previous ones are false it means that this place is new.
                    else {
                        let alert = UIAlertController(title: "Great suggestion!", message: "Thanks for your effort, we will review and insert the place as soon as possible.", preferredStyle: UIAlertController.Style.alert)
                        
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (action) in
                            self.dismiss(animated: true, completion: nil)
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocationServices()
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

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .notDetermined {
            configureLocationServices()
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
