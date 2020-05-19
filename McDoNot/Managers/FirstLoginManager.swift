//
//  FirstLoginManager.swift
//  McDoNot
//
//  Created by Massimo Maddaluno on 23/02/2020.
//  Copyright © 2020 McDoNot. All rights reserved.
//

import Firebase
import Foundation

/// Thie class which handles the first Login on the application.
class FirstLoginManager {
    static let shared = FirstLoginManager()

    private init() {
    }

    var userID = UIDevice.current.identifierForVendor!.uuidString

    /// Call this function as one of the first things after the application is launched, it checks if the user exists or not in the database and if it doesn't the function will add it.
    func loginProcedure(db: Firestore) {
        if JsonManager.shared.load() {
            return
        } else {
            DBManager.shared.addUser(db: db, userID: userID)
            JsonManager.shared.save(value: true)
        }
    }
}
