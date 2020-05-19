//
//  SuggestedPlace.swift
//  McDoNot
//
//  Created by Massimo Maddaluno on 19/02/2020.
//  Copyright © 2020 McDoNot. All rights reserved.
//

import Foundation
import MapKit

struct SuggestedPlace: Decodable {
    var accessibility: Int
    var address: String
    var foodSelling: Int
    var freeParking: Int
    var ID: String
    var imageURL: String
    var isSilent: Int
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var name: String
    var plug: Int
    var smokingArea: Int
    var suggestionCount: Int
    var type: String
    var vendingMachine: Int
    var wiFi: Int
}
