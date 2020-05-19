//
//  Places.swift
//  McDoNot
//
//  Created by Massimo Maddaluno on 18/02/2020.
//  Copyright © 2020 McDoNot. All rights reserved.
//

import Foundation
import MapKit

struct Place: Decodable {
    var accessibility: Bool
    var address: String
    var foodSelling: Bool
    var freeParking: Bool
    var ID: String
    var imageURL: String
    var isSilent: Bool
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var name: String
    var plug: Bool
    var rating: Double
    var ratingCount: Int
    var smokingArea: Bool
    var type: String
    var vendingMachine: Bool
    var wiFi: Bool
}
