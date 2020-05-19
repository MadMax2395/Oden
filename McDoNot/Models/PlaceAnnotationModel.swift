//
//  PlaceAnnotationModel.swift
//  McDoNot
//
//  Created by david florczak on 22/02/2020.
//  Copyright © 2020 McDoNot. All rights reserved.
//

import MapKit

class PlaceAnnotationModel: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D

    enum placeType {
        case cafe
        case library
        case outdoor
    }

    var type = placeType.library

    init(place: Place) {
        coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
        location = place
    }
    
    var location: Place?
}
