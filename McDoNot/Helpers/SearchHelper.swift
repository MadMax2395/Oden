//
//  SearchHelper.swift
//  McDoNot
//
//  Created by Roberto Scarpati on 24/02/2020.
//  Copyright © 2020 McDoNot. All rights reserved.
//

import Foundation
import MapKit

func filterPlacesList(places: [Place], accessibility: Bool, foodSelling: Bool, freeParking: Bool, plug: Bool, smokingArea: Bool, vendingMachine: Bool, wiFi: Bool) -> [Place] {
    var returnList: [Place] = []

    for place in places {
        if (accessibility == place.accessibility || !accessibility) &&
            (foodSelling == place.foodSelling || !foodSelling) &&
            (freeParking == place.freeParking || !freeParking) &&
            (plug == place.plug || !plug) &&
            (smokingArea == place.smokingArea || !smokingArea) &&
            (vendingMachine == place.vendingMachine || !vendingMachine) &&
            (wiFi == place.wiFi || !wiFi) {
            returnList.append(place)
        }
    }

    return returnList
}
