//
//  DBManager.swift
//  McDoNot
//
//  Created by Massimo Maddaluno on 18/02/2020.
//  Copyright © 2020 McDoNot. All rights reserved.
//

import Firebase
import Foundation
import MapKit


struct InsertionInfo{
    var suggestionJustInserted: Bool
    var placeAlreadyPresent: Bool
}

struct InsertionInfo2{
    var suggestionJustInserted: Bool
    var placeAlreadyPresent: Bool
    var docPointer: DocumentReference
    var docData: [String: Any]
}

struct BoolInfo{
    var suggestionJustInserted: Bool
    var placeAlreadyPresent: Bool
}



/// The class which handles database-related functions.
class DBManager {
    private init() {
    }

    /// Use the istance of this class to call methods.
    static let shared = DBManager()

    //    MARK: -CREATE

    /// Call this function to add a User in the Database.
    func addUser(db: Firestore, userID: String) {
        checkUser(db: db, userID: userID) { userExist in
            if !userExist {
                db.collection("Users").addDocument(data:
                    [
                        "ID": userID,
                    ]
                )
            } else {
            }
        }
    }

    /// Call this function in order to add a rating related to a place and a user.
    func addRating(db: Firestore, userID: String, place: Place, value: Int) {
        retrieveUserReference(db: db, userID: userID) { userReference in
            self.retrievePlaceReference(db: db, place: place) { placeReference in
                self.retrieveRatingID(db: db, userID: userReference, place: placeReference) { ratingID in
                    if ratingID != "" {
                        db.collection("Ratings").document(ratingID).getDocument {
                            snapshot, error in

                            if let err = error {
                                print(err.localizedDescription)
                            } else {
                                let doc = snapshot!.reference

                                doc.updateData(["value": value])
                            }
                        }
                    } else {
                        db.collection("Ratings").addDocument(data:
                            [
                                "value": value,
                                "userID": userReference,
                                "verifiedPlace": placeReference,
                        ])
                    }
                }
            }
        }
    }

    /// Call this function in order to add a suggested place in the Database.
    func addSuggestedPlace(db: Firestore, place: SuggestedPlace, completionHandler: @escaping (Bool) -> Void) {
        var userJustInserted: Bool = false

        db.collection("SuggestedPlaces").whereField("latitude", isEqualTo: place.latitude).whereField("longitude", isEqualTo: place.longitude).getDocuments {
            snapshot, error in

            if let err = error {
                print(err.localizedDescription)
            } else {
                let accessibilityCounter = Int(truncating: NSNumber(value: place.accessibility))
                let foodSellingCounter = Int(truncating: NSNumber(value: place.foodSelling))
                let freeParkingCounter = Int(truncating: NSNumber(value: place.freeParking))
                let isSilentCounter = Int(truncating: NSNumber(value: place.isSilent))
                let plugCounter = Int(truncating: NSNumber(value: place.plug))
                let smokingAreaCounter = Int(truncating: NSNumber(value: place.smokingArea))
                let vendingMachineCounter = Int(truncating: NSNumber(value: place.vendingMachine))
                let wiFiCounter = Int(truncating: NSNumber(value: place.wiFi))

                if snapshot?.isEmpty ?? true {
                    userJustInserted = true

                    db.collection("SuggestedPlaces").addDocument(data:
                        [
                            "latitude": place.latitude,
                            "longitude": place.longitude,
                            "name": place.name,
                            "accessibility": accessibilityCounter,
                            "address": place.address,
                            "foodSelling": foodSellingCounter,
                            "freeParking": freeParkingCounter,
                            "ID": place.ID,
                            "imageURL": place.imageURL,
                            "isSilent": isSilentCounter,
                            "plug": plugCounter,
                            "smokingArea": smokingAreaCounter,
                            "suggestionCount": 1,
                            "type": place.type,
                            "vendingMachine": vendingMachineCounter,
                            "wiFi": wiFiCounter])
                }
            }
//            print(userJustInserted)

            completionHandler(userJustInserted)
        }
    }

    //    MARK: -READ

    /// Call this function in order to  download a list of Places contained in a circle of given radius and center.
    func downloadRangePlace(db: Firestore, offsetRadiusKm: CGFloat, location: CLLocation, completionHandler: @escaping ([Place]) -> Void) {
        var listTemp: [Place] = []

        let offsetLatitude = CLLocationDegrees(offsetRadiusKm / 110.574)

        let angleLatitudeToRadiant = CGFloat(CGFloat.pi * CGFloat(offsetLatitude) / 180)

        let offsetLongitude = CLLocationDegrees(offsetRadiusKm / (offsetRadiusKm * CGFloat(cos(angleLatitudeToRadiant))))

        let supLat = location.coordinate.latitude + offsetLatitude

        let infLat = location.coordinate.latitude - offsetLatitude

        let supLong = location.coordinate.longitude + offsetLongitude

        let infLong = location.coordinate.longitude - offsetLongitude

        db.collection("Places").whereField("latitude", isLessThan: supLat).whereField("latitude", isGreaterThan: infLat).getDocuments {
            snapshot, err in
            if err == nil && snapshot != nil {
                for document in snapshot!.documents {
                    let documentData = document.data()

                    if CGFloat(documentData["longitude"] as! CLLocationDegrees) <= CGFloat(supLong) &&
                        CGFloat(documentData["longitude"] as! CLLocationDegrees) >= CGFloat(infLong) {
                        listTemp.append(Place(
                            accessibility: documentData["accessibility"] as! Bool,
                            address: documentData["address"] as! String,
                            foodSelling: documentData["foodSelling"] as! Bool,
                            freeParking: documentData["freeParking"] as! Bool,
                            ID: documentData["ID"] as! String,
                            imageURL: documentData["imageURL"] as! String,
                            isSilent: documentData["isSilent"] as! Bool,
                            latitude: documentData["latitude"] as! CLLocationDegrees,
                            longitude: documentData["longitude"] as! CLLocationDegrees,
                            name: documentData["name"] as! String,
                            plug: documentData["plug"] as! Bool,
                            rating: documentData["rating"] as! Double,
                            ratingCount: documentData["ratingCount"] as! Int,
                            smokingArea: documentData["smokingArea"] as! Bool,
                            type: documentData["type"] as! String,
                            vendingMachine: documentData["vendingMachine"] as! Bool,
                            wiFi: documentData["wiFi"] as! Bool))
                    }
                }
            }

            struct tempStruct {
                var place: Place
                var distance: Double
            }

//            typealias TempTuple = (place: Place, initialIndex: Int, distance: Double)

            var array = [tempStruct]()

            for i in 0 ..< listTemp.count {
                let coord = CLLocation(latitude: listTemp[i].latitude, longitude: listTemp[i].longitude)
                array.append(tempStruct(place: listTemp[i], distance: location.distance(from: coord)))
            }

            array.sort(by: { $0.distance <= $1.distance })

            var places = [Place]()

            for i in 0 ..< array.count {
                places.append(array[i].place)
            }

            completionHandler(places)
        }
    }

    /// Call this function in order to download the user favourite places .
    func downloadFavPlaces(db: Firestore, userID: String, completionHandler: @escaping ([Place]) -> Void) {
        var listTemp: [Place] = []

        db.collection("Users").whereField("ID", isEqualTo: userID).getDocuments {
            snapshot, error in
            if let err = error {
                print(err.localizedDescription)
            }

            for document in snapshot!.documents {
                let documentData = document.data()

                if documentData["favouritePlaces"] == nil {
                    completionHandler(listTemp)
                } else {
                    let tempList = documentData["favouritePlaces"] as! [DocumentReference]

                    for (_, value) in tempList.enumerated() {
                        value.getDocument {
                            snapshot2, error2 in
                            if let err2 = error2 {
                                print(err2.localizedDescription)
                            }

                            let doc = snapshot2?.data()

                            let t = Place(
                                accessibility: doc!["accessibility"] as! Bool,
                                address: doc!["address"] as! String,
                                foodSelling: doc!["foodSelling"] as! Bool,
                                freeParking: doc!["freeParking"] as! Bool,
                                ID: doc!["ID"] as! String,
                                imageURL: doc!["imageURL"] as! String,
                                isSilent: doc!["isSilent"] as! Bool,
                                latitude: doc!["latitude"] as! CLLocationDegrees,
                                longitude: doc!["longitude"] as! CLLocationDegrees,
                                name: doc!["name"] as! String,
                                plug: doc!["plug"] as! Bool,
                                rating: doc!["rating"] as! Double,
                                ratingCount: doc!["ratingCount"] as! Int,
                                smokingArea: doc!["smokingArea"] as! Bool,
                                type: doc!["type"] as! String,
                                vendingMachine: doc!["vendingMachine"] as! Bool,
                                wiFi: doc!["wiFi"] as! Bool
                            )

                            listTemp.append(t)

                            if listTemp.count == tempList.count {
                                completionHandler(listTemp)
                            }
                        }
                    }
                }
            }
        }
    }

    /// Call this function to download all the Places on the database
    func downloadPlace(db: Firestore, completionHandler: @escaping ([Place]) -> Void) {
        var listTemp: [Place] = []

        db.collection("Places").getDocuments {
            snapshot, err in
            if err == nil && snapshot != nil {
                for document in snapshot!.documents {
                    let documentData = document.data()

                    listTemp.append(Place(
                        accessibility: documentData["accessibility"] as! Bool,
                        address: documentData["address"] as! String,
                        foodSelling: documentData["foodSelling"] as! Bool,
                        freeParking: documentData["freeParking"] as! Bool,
                        ID: documentData["ID"] as! String,
                        imageURL: documentData["imageURL"] as! String,
                        isSilent: documentData["isSilent"] as! Bool,
                        latitude: documentData["latitude"] as! CLLocationDegrees,
                        longitude: documentData["longitude"] as! CLLocationDegrees,
                        name: documentData["name"] as! String,
                        plug: documentData["plug"] as! Bool,
                        rating: documentData["rating"] as! Double,
                        ratingCount: documentData["ratingCount"] as! Int,
                        smokingArea: documentData["smokingArea"] as! Bool,
                        type: documentData["type"] as! String,
                        vendingMachine: documentData["vendingMachine"] as! Bool,
                        wiFi: documentData["wiFi"] as! Bool))
                }
            }
            let locationManager = CLLocationManager()

            struct tempStruct {
                var place: Place
                var distance: Double
            }

            //            typealias TempTuple = (place: Place, initialIndex: Int, distance: Double)

            var array = [tempStruct]()
            
            if locationManager.location != nil {
                for i in 0 ..< listTemp.count {
                    let coord = CLLocation(latitude: listTemp[i].latitude, longitude: listTemp[i].longitude)
                    array.append(tempStruct(place: listTemp[i], distance: locationManager.location!.distance(from: coord)))
                }

                array.sort(by: { $0.distance <= $1.distance })

                var places = [Place]()

                for i in 0 ..< array.count {
                    places.append(array[i].place)
                }

                completionHandler(places)
            } else {
                completionHandler(listTemp)
            }
            
            
        }
    }

    /// Call this function to insert a place in the user favourites.
    func addPlaceToFavourites(db: Firestore, place: Place, userID: String, completionHandler: @escaping (Bool) -> Void) {
        retrievePlaceReference(db: db, place: place) { id in
            db.collection("Users").whereField("ID", isEqualTo: userID).getDocuments {
                snapshot, error in
                if let err = error {
                    print(err.localizedDescription)
                } else {
                    let documentData = snapshot?.documents.first

                    documentData?.reference.updateData(["favouritePlaces": FieldValue.arrayUnion([id])])
                }

                completionHandler(true)
            }
        }
    }

    /// Call this function to retrieve the reference in the Database of a verified place.
    func retrievePlaceReference(db: Firestore, place: Place, completionHandler: @escaping (DocumentReference) -> Void) {
        var id: DocumentReference!

        db.collection("Places").whereField("latitude", isEqualTo: place.latitude).whereField("longitude", isEqualTo: place.longitude).getDocuments {
            snapshot, error in

            if let err = error {
                print(err.localizedDescription)
            } else {
                if !(snapshot?.isEmpty ?? true) {
                    let doc = (snapshot?.documents.first)!

                    id = doc.reference
                }
            }

            completionHandler(id)
        }
    }

    /// Call this function to retrieve the ID iin the Database of a verified place.
    func retrievePlaceID(db: Firestore, place: Place, completionHandler: @escaping (String) -> Void) {
        var id: String = ""

        db.collection("Places").whereField("latitude", isEqualTo: place.latitude).whereField("longitude", isEqualTo: place.longitude).getDocuments {
            snapshot, error in

            if let err = error {
                print(err.localizedDescription)
            } else {
                if !(snapshot?.isEmpty ?? true) {
                    let doc = (snapshot?.documents.first)!
                    id = doc.documentID
                }
            }

            completionHandler(id)
        }
    }

    /// Call this function to retrieve the ID iin the Database of a verified place.
    func retrieveUserReference(db: Firestore, userID: String, completionHandler: @escaping (DocumentReference) -> Void) {
        var id: DocumentReference!

        db.collection("Users").whereField("ID", isEqualTo: userID).getDocuments {
            snapshot, error in

            if let err = error {
                print(err.localizedDescription)
            } else {
                if !(snapshot?.isEmpty ?? true) {
                    let doc = (snapshot?.documents.first)!

                    id = doc.reference
                }
            }

            completionHandler(id)
        }
    }

    /// Call this function to check if a user exists or not.
    func checkUser(db: Firestore, userID: String, completionHandler: @escaping (Bool) -> Void) {
        db.collection("Users").whereField("ID", isEqualTo: userID).getDocuments {
            snapshot, error in
            if let err = error {
                print(err.localizedDescription)
            }

            var userExists: Bool = false

            let doc = snapshot?.documents.first

            let documentData = doc?.data()

            if documentData?.isEmpty ?? true {
                userExists = false
            } else {
                userExists = true
            }

            completionHandler(userExists)
        }
    }

    /// Call this function to load the ID of a rating related to a place and a user
    func retrieveRatingID(db: Firestore, userID: DocumentReference, place: DocumentReference, completionHandler: @escaping (String) -> Void) {
        db.collection("Ratings").whereField("userID", isEqualTo: userID).whereField("verifiedPlace", isEqualTo: place).getDocuments {
            snapshot, error in
            if let err = error {
                print(err.localizedDescription)
            }

            let doc = snapshot?.documents.first

            let docID = doc?.documentID

            completionHandler(docID ?? "")
        }
    }

    //    MARK: -UPDATE

    /// Call this function to update the suggestioncount of a suggested place, also call this function to add a place without handling with completion handler of addSuggestedPlace.
    func updateCountSuggestion(db: Firestore, place: SuggestedPlace, completionHandler: @escaping (InsertionInfo) -> Void) {
        addSuggestedPlace(db: db, place: place) { suggestionJustInserted in
            
            var insertionInfo = InsertionInfo(suggestionJustInserted: suggestionJustInserted, placeAlreadyPresent: false)
            var suggestionCount = 50
            if insertionInfo.suggestionJustInserted == false {
                let accessibilityCounter = Int(truncating: NSNumber(value: place.accessibility))
                let foodSellingCounter = Int(truncating: NSNumber(value: place.foodSelling))
                let freeParkingCounter = Int(truncating: NSNumber(value: place.freeParking))
                let isSilentCounter = Int(truncating: NSNumber(value: place.isSilent))
                let plugCounter = Int(truncating: NSNumber(value: place.plug))
                let smokingAreaCounter = Int(truncating: NSNumber(value: place.smokingArea))
                let vendingMachineCounter = Int(truncating: NSNumber(value: place.vendingMachine))
                let wiFiCounter = Int(truncating: NSNumber(value: place.wiFi))

                db.collection("SuggestedPlaces").whereField("latitude", isEqualTo: place.latitude).whereField("longitude", isEqualTo: place.longitude).getDocuments {
                    snapshot, error in
                    if let err = error {
                        print(err.localizedDescription)
                    } else {
                        let doc = (snapshot?.documents.first)!

                        let docRef = doc.reference
                        
                        suggestionCount = doc.data()["suggestionCount"] as! Int
                        
                        if suggestionCount < 10 {
                           docRef.updateData([
                                "suggestionCount": suggestionCount + 1,
                                "accessibility": doc.data()["accessibility"] as! Int + accessibilityCounter,
                                "foodSelling": doc.data()["foodSelling"] as! Int + foodSellingCounter,
                                "freeParking": doc.data()["freeParking"] as! Int + freeParkingCounter,
                                "isSilent": doc.data()["isSilent"] as! Int + isSilentCounter,
                                "plug": doc.data()["plug"] as! Int + plugCounter,
                                "smokingArea": doc.data()["smokingArea"] as! Int + smokingAreaCounter,
                                "vendingMachine": doc.data()["vendingMachine"] as! Int + vendingMachineCounter,
                                "wiFi": doc.data()["wiFi"] as! Int + wiFiCounter
                                
                            ]) { (err) in
                                completionHandler(insertionInfo)
                            }
                        }
                        
                        else{
                            insertionInfo.placeAlreadyPresent = true
                            completionHandler(insertionInfo)
                        }

                    }

                }
    

            }
            else{
                completionHandler(insertionInfo)
            }


            
        }
    }
    
    
    func updateSuggestionFeatures(db: Firestore, place: SuggestedPlace, features: Features, completionHandler: @escaping (Bool) -> Void){
        db.collection("SuggestedPlaces").whereField("latitude", isEqualTo: place.latitude).whereField("longitude", isEqualTo: place.longitude).getDocuments { (snapshot, err) in
            
            let accessibilityCounter = Int(truncating: NSNumber(value: features.accessibility))
            let foodSellingCounter = Int(truncating: NSNumber(value: features.foodSelling))
            let freeParkingCounter = Int(truncating: NSNumber(value: features.freeParking))
            let isSilentCounter = Int(truncating: NSNumber(value: features.isSilent))
            let plugCounter = Int(truncating: NSNumber(value: features.plug))
            let smokingAreaCounter = Int(truncating: NSNumber(value: features.smokingArea))
            let vendingMachineCounter = Int(truncating: NSNumber(value: features.vendingMachine))
            let wiFiCounter = Int(truncating: NSNumber(value: features.wiFi))
            
            
            if let error = err{
                print(error.localizedDescription)
            }
            else{
                let doc = (snapshot?.documents.first)!
                let docRef = doc.reference
                let suggestionCount = doc.data()["suggestionCount"] as! Int
                docRef.updateData([
                    "suggestionCount": suggestionCount + 1,
                    "accessibility": doc.data()["accessibility"] as! Int + accessibilityCounter,
                    "foodSelling": doc.data()["foodSelling"] as! Int + foodSellingCounter,
                    "freeParking": doc.data()["freeParking"] as! Int + freeParkingCounter,
                    "isSilent": doc.data()["isSilent"] as! Int + isSilentCounter,
                    "plug": doc.data()["plug"] as! Int + plugCounter,
                    "smokingArea": doc.data()["smokingArea"] as! Int + smokingAreaCounter,
                    "vendingMachine": doc.data()["vendingMachine"] as! Int + vendingMachineCounter,
                    "wiFi": doc.data()["wiFi"] as! Int + wiFiCounter
                    
                ])
                
            }
            completionHandler(true)
        }
    }
    

    //    MARK: -DELETE

    /// Call this function to remove a place from the user favourites.
    func removePlaceFromFavourites(db: Firestore, place: Place, userID: String, completionHandler: @escaping (Bool) -> Void) {
        retrievePlaceReference(db: db, place: place) { id in
            db.collection("Users").whereField("ID", isEqualTo: userID).getDocuments {
                snapshot, error in
                if let err = error {
                    print(err.localizedDescription)
                } else {
                    let documentData = snapshot?.documents.first
                    documentData?.reference.updateData(["favouritePlaces": FieldValue.arrayRemove([id])])
                }

                completionHandler(true)
            }
        }
    }
    
    
    
    func createSuggestion(db: Firestore, place: SuggestedPlace, completionHandler: @escaping (InsertionInfo2) -> Void){
    
    
    db.runTransaction({ (transaction, errorPointer) -> Any? in
        let docRef = db.collection("SuggestedPlaces").document()
        var info = InsertionInfo2(suggestionJustInserted: false, placeAlreadyPresent: false, docPointer: docRef, docData: [:])
        
        db.collection("suggestedPlaces").whereField("latitude", isEqualTo: place.latitude).whereField("longitude", isEqualTo: place.longitude).getDocuments{ snapshot, err in
            if let error = err{
                print(error.localizedDescription)
            }
            else{
                let accessibilityCounter = Int(truncating: NSNumber(value: place.accessibility))
                let foodSellingCounter = Int(truncating: NSNumber(value: place.foodSelling))
                let freeParkingCounter = Int(truncating: NSNumber(value: place.freeParking))
                let isSilentCounter = Int(truncating: NSNumber(value: place.isSilent))
                let plugCounter = Int(truncating: NSNumber(value: place.plug))
                let smokingAreaCounter = Int(truncating: NSNumber(value: place.smokingArea))
                let vendingMachineCounter = Int(truncating: NSNumber(value: place.vendingMachine))
                let wiFiCounter = Int(truncating: NSNumber(value: place.wiFi))
                
                if snapshot?.isEmpty ?? true {
                    info.suggestionJustInserted = true
                    
                    
                    transaction.setData([
                        "latitude": place.latitude,
                        "longitude": place.longitude,
                        "name": place.name,
                        "accessibility": accessibilityCounter,
                        "address": place.address,
                        "foodSelling": foodSellingCounter,
                        "freeParking": freeParkingCounter,
                        "ID": place.ID,
                        "imageURL": place.imageURL,
                        "isSilent": isSilentCounter,
                        "plug": plugCounter,
                        "smokingArea": smokingAreaCounter,
                        "suggestionCount": 1,
                        "type": place.type,
                        "vendingMachine": vendingMachineCounter,
                        "wiFi": wiFiCounter], forDocument: docRef)
    
    
    }
                    else{
                        info.docData = (snapshot?.documents.first?.data())!
                        info.docPointer = (snapshot?.documents.first!.reference)!
                    }
                }
            }
            return info
        }) { (object, error) in
            print("Transaction completed successfully")
            completionHandler(object as! InsertionInfo2)
        }
    }
    
    
    
    /// Test function
    func createUpdateSuggestion(db: Firestore, place: SuggestedPlace, completionHandler: @escaping (BoolInfo) -> Void){
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            
            var infoToReturn = BoolInfo(suggestionJustInserted: false, placeAlreadyPresent: false)
            
            self.createSuggestion(db: db, place: place) { (info) in
                
                infoToReturn.suggestionJustInserted = info.suggestionJustInserted
                
                if info.suggestionJustInserted == false {
                        let accessibilityCounter = Int(truncating: NSNumber(value: place.accessibility))
                        let foodSellingCounter = Int(truncating: NSNumber(value: place.foodSelling))
                        let freeParkingCounter = Int(truncating: NSNumber(value: place.freeParking))
                        let isSilentCounter = Int(truncating: NSNumber(value: place.isSilent))
                        let plugCounter = Int(truncating: NSNumber(value: place.plug))
                        let smokingAreaCounter = Int(truncating: NSNumber(value: place.smokingArea))
                        let vendingMachineCounter = Int(truncating: NSNumber(value: place.vendingMachine))
                        let wiFiCounter = Int(truncating: NSNumber(value: place.wiFi))
                        
                        
                    let suggestionCount = info.docData["suggestionCount"] as! Int
                        let accessibilityOldCount = info.docData["accessibility"] as! Int
                        let foodSellingOldCount = info.docData["foodSelling"] as! Int
                        let freeParkingOldCount = info.docData["freeParking"] as! Int
                        let isSilentOldCount = info.docData["isSilent"] as! Int
                        let plugOldCount = info.docData["plug"] as! Int
                        let smokingAreaOldCount = info.docData["smokingArea"] as! Int
                        let vendingMachineOldCount = info.docData["vendingMachine"] as! Int
                        let wiFiOldCount = info.docData["wiFi"] as! Int
                        
                        if suggestionCount < 10 {
                            transaction.updateData([
                                
                                "suggestionCount": suggestionCount + 1,
                                "accessibility": accessibilityOldCount + accessibilityCounter,
                                "foodSelling": foodSellingOldCount + foodSellingCounter,
                                "freeParking": freeParkingOldCount + freeParkingCounter,
                                "isSilent": isSilentOldCount + isSilentCounter,
                                "plug": plugOldCount + plugCounter,
                                "smokingArea": smokingAreaOldCount + smokingAreaCounter,
                                "vendingMachine": vendingMachineOldCount + vendingMachineCounter,
                                "wiFi": wiFiOldCount + wiFiCounter],
                                                   forDocument: info.docPointer)
                        }
                            
                        else{
                            infoToReturn.placeAlreadyPresent = true
                        }
                        
                    }
                
            }
            
            return  infoToReturn
        }) { (object, err) in
            if let error = err{
                print(error.localizedDescription)
            }
            else{
                print("Transaction completed successfully \(String(describing: object))")
                            completionHandler(object as! BoolInfo)
                        }
                    }
                    
                    
                }
    
    
    
    
    
    
    
    
}
