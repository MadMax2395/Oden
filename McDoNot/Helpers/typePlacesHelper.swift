//
//  typePlacesHelper.swift
//  McDoNot
//
//  Created by Fabio Staiano on 04/03/2020.
//  Copyright © 2020 McDoNot. All rights reserved.
//

import Foundation
import MapKit


func translateTypeOfPlace(type: MKPointOfInterestCategory?) -> String {
    switch type {
    case MKPointOfInterestCategory.cafe:
        return NSLocalizedString("Cafè", comment: "Cafè")
    case MKPointOfInterestCategory.bakery:
        return NSLocalizedString("Bakery", comment: "Bakery")
    case MKPointOfInterestCategory.library:
        return NSLocalizedString("Library", comment: "Library")
    case MKPointOfInterestCategory.school:
        return NSLocalizedString("School", comment: "School")
    case MKPointOfInterestCategory.university:
        return NSLocalizedString("University", comment: "University")
    case MKPointOfInterestCategory.park:
        return NSLocalizedString("Park", comment: "Park")
    case MKPointOfInterestCategory.store:
        return NSLocalizedString("Store", comment: "Store")
    default:
        return NSLocalizedString("Spot", comment: "Spot")
    }
}
