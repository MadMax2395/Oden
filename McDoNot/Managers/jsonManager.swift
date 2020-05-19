//
//  jsonManager.swift
//  McDoNot
//
//  Created by Massimo Maddaluno on 20/02/2020.
//  Copyright © 2020 McDoNot. All rights reserved.
//


import Foundation

///The class which handles the json file.
class JsonManager{
    
    static let shared = JsonManager()
    
    private init(){
        
    }
    
    ///Call this function in order to load the bool value related to firstLogin field in firstLogin.json
   func load() -> Bool {
    
    var temp = userLogin()
        do {
            let fileURL = try FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent("firstLogin.json")

            let data = try Data(contentsOf: fileURL)
            temp = try JSONDecoder().decode(userLogin.self, from: data)
        } catch {
            print(error)
        }
    
    return temp.firstLogin
    }

     ///Call this function in order to update the value  related to firstLogin field in firstLogin.json
     func save(value: Bool) {
        let t = userLogin(firstLogin: value)
        do {
            let fileURL = try FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("firstLogin.json")

            try JSONEncoder().encode(t)
                .write(to: fileURL)
        } catch {
            print(error)
        }
    }
}

struct userLogin: Codable{
    var firstLogin = Bool()
}
