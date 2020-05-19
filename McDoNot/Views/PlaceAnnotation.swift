//
//  CustomMap.swift
//  McDoNot
//
//  Created by david florczak on 21/02/2020.
//  Copyright © 2020 McDoNot. All rights reserved.
//

import MapKit

private let studyPlaceID = "studyPlace"

/// - Tag: LibraryAnnotationView
class LibraryAnnotationView: MKMarkerAnnotationView {
    static let ReuseID = "libraryAnnotation"

    /// - Tag: ClusterIdentifier
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clusteringIdentifier = "library" // unicycle
        cluster?.backgroundColor = #colorLiteral(red: 0.6013525128, green: 0.6408324838, blue: 0.8475896716, alpha: 1)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForDisplay() {
        super.prepareForDisplay()
        displayPriority = .defaultLow
//        markerTintColor = UIColor.libraryColor
        markerTintColor = #colorLiteral(red: 0.2393253446, green: 0.2212072909, blue: 0.4622101188, alpha: 1)

        glyphImage = #imageLiteral(resourceName: "Pin icon")
    }
}

/// - Tag: CafeAnnotationView
class CafeAnnotationView: MKMarkerAnnotationView {
    static let ReuseID = "cafeAnnotation"

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clusteringIdentifier = studyPlaceID
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// - Tag: DisplayConfiguration
    override func prepareForDisplay() {
        super.prepareForDisplay()
        displayPriority = .defaultHigh
//        markerTintColor = UIColor.bicycleColor
        markerTintColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        glyphImage = #imageLiteral(resourceName: "Bar")
    }
}

class OutdoorAnnotationView: MKMarkerAnnotationView {
    static let ReuseID = "outdoorAnnotation"

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clusteringIdentifier = studyPlaceID
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForDisplay() {
        super.prepareForDisplay()
        displayPriority = .defaultHigh
//        markerTintColor = UIColor.tricycleColor
        markerTintColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
        glyphImage = #imageLiteral(resourceName: "Bar")
    }
}
