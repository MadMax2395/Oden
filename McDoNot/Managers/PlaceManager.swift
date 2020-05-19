//
//  PlaceManager.swift
//  McDoNot
//
//  Created by Massimo Maddaluno on 28/02/2020.
//  Copyright © 2020 McDoNot. All rights reserved.
//

import Firebase
import Foundation
import MapKit

class PlaceManager {
    static let shared = PlaceManager()

    public var listPlace: [Place] = []
    public var listFavouritePlaces: [Place] = []
    public var listRangePlaces: [Place] = []
    private let db = Firestore.firestore()

    private init() {
    }

    func downloadPlace(completionHandler: @escaping (Bool) -> Void) {
        DBManager.shared.downloadPlace(db: db) { list in
            self.listPlace = list

            completionHandler(true)
        }
    }

    func downloadFavPlace(completionHandler: @escaping (Bool) -> Void) {
        DBManager.shared.downloadFavPlaces(db: db, userID: FirstLoginManager.shared.userID) { list in
            self.listFavouritePlaces = list

            completionHandler(true)
        }
    }

    func downloadRangePlace(offsetRadiusKm: CGFloat, location: CLLocation, completionHandler: @escaping (Bool) -> Void) {
        DBManager.shared.downloadRangePlace(db: db, offsetRadiusKm: offsetRadiusKm, location: location) { list in
            self.listRangePlaces = list

            completionHandler(true)
        }
    }
}
