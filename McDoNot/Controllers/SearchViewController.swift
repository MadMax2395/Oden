//
//  SearchViewController.swift
//  AutocompleteExample
//
//  Created by Fabbio on 03/03/2020.
//  Copyright © 2020 McDoNot. All rights reserved.
//

import UIKit
import MapKit
import Foundation


class SearchViewController: UISearchController {
    
    
    deinit {
        print("\(self) SearchViewController has been deinitialized")
    }
    
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    
    var searchResultsTableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        searchCompleter.delegate = self
        searchBar.delegate = self
        searchResultsTableView.dataSource = self
        searchResultsTableView.delegate = self
        
        searchResultsTableView.frame = CGRect(x: 0, y: self.searchBar.frame.size.height, width: self.view.frame.size.width, height: self.view.frame.size.height - self.searchBar.frame.size.height)
        
        self.view.addSubview(searchResultsTableView)
    }
    
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchCompleter.queryFragment = searchText
        searchCompleter.resultTypes = .pointOfInterest
    }
}

extension SearchViewController: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        searchResultsTableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
    }
}

extension SearchViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchResult = searchResults[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = searchResult.title
        cell.detailTextLabel?.text = searchResult.subtitle
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let completion = searchResults[indexPath.row]
        
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            let tempUserInfo: [String: MKMapItem] = ["place": (response?.mapItems[0])!]
            
            self.dismiss(animated: true) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "gettingObject"), object: nil, userInfo: tempUserInfo)
            }
        }
    }
}
