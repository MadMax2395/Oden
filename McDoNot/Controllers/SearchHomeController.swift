//
//  Test.swift
//  McDoNot
//
//  Created by Massimo Maddaluno on 10/03/2020.
//  Copyright © 2020 McDoNot. All rights reserved.
//

import UIKit
import MapKit
import Foundation
import CoreLocation

class SearchHomeController: UIViewController, CLLocationManagerDelegate{

    
    deinit {
        print("\(self) SearchHomeController has been deinitialized")
    }
    
    
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
//    var sectionOneIsActive = false
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var placesTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchCompleter.delegate = self
        searchBar.delegate = self
        placesTable.dataSource = self
        placesTable.delegate = self
        
    }

    
}


extension SearchHomeController: UITableViewDelegate, UITableViewDataSource{
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections

        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
       
        return searchResults.count
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        var cell = UITableViewCell()
        //        if indexPath.section == 0{
        //            if sectionOneIsActive{
        //                cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        //                cell.textLabel?.text = "Your position"
        //                return cell
        //            }
        //            else{
        let searchResult = searchResults[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = searchResult.title
        cell.detailTextLabel?.text = searchResult.subtitle
        return cell
        //            }
        //        }
        //        if indexPath.section == 1{
        //            let searchResult = searchResults[indexPath.row]
        //            cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        //            cell.textLabel?.text = searchResult.title
        //            cell.detailTextLabel?.text = searchResult.subtitle
        //            return cell
        //        }
        //        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
//
//        if indexPath.section == 0{
//            if sectionOneIsActive{
//                let tempUserInfo: [String: MKMapItem] = ["place": MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!)))]
//                self.dismiss(animated: true) {
//                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "gettingObject"), object: nil, userInfo: tempUserInfo)
//                }
//
//            }
//            else{
                let completion = searchResults[indexPath.row]
                let searchRequest = MKLocalSearch.Request(completion: completion)
                let search = MKLocalSearch(request: searchRequest)
                search.start { (response, error) in
                    let tempUserInfo: [String: MKMapItem] = ["place": (response?.mapItems[0])!]
                    
                    self.dismiss(animated: true) {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "gettingObject"), object: nil, userInfo: tempUserInfo)
                    }
                }
//            }
//        }
//        else{
//            let completion = searchResults[indexPath.row]
//            let searchRequest = MKLocalSearch.Request(completion: completion)
//            let search = MKLocalSearch(request: searchRequest)
//            search.start { (response, error) in
//                let tempUserInfo: [String: MKMapItem] = ["place": (response?.mapItems[0])!]
//
//                self.dismiss(animated: true) {
//                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "gettingObject"), object: nil, userInfo: tempUserInfo)
//                }
//            }
//        }
    }
    
}


extension SearchHomeController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchCompleter.queryFragment = searchText
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismiss(animated: true) {
            
    }
}
    
}

extension SearchHomeController: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        self.placesTable.reloadData()
    }

}
//
//extension Test{
//    
//    
//    func configureLocationServices() {
//        // Ask for Authorisation from the User.
//        locationManager.requestAlwaysAuthorization()
//        
//        // For use in foreground
//        locationManager.requestWhenInUseAuthorization()
//        
//        if CLLocationManager.locationServicesEnabled() {
//            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//            locationManager.startUpdatingLocation()
//        }
//    }
//    
//    
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        if status == .authorizedAlways || status == .authorizedWhenInUse {
//            if locationManager.location != nil {
//                PlaceManager.shared.downloadRangePlace(offsetRadiusKm: 25, location: locationManager.location!) { test in
//                    
//                    if !test {
//                        print("******ERROR******")
//                    }
//                    
//                    self.placesTable.reloadData()
//                }
//            }
//        }
//        
//        if status == .notDetermined {
//            configureLocationServices()
//        }
//        
//    }
//    
//    
//}
