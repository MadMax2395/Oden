//
//  Tag.swift
//  McDoNot
//
//  Created by Massimo Maddaluno on 24/02/2020.
//  Copyright © 2020 McDoNot. All rights reserved.
//

import Foundation
import UIKit

struct Tag {
    var availability: Bool
    var imageName: String
    var used: Bool
}

func findNextAvailable(vector: inout [Tag], baseIndex: Int) -> Int {
    for i in baseIndex ..< vector.count {
        if vector[i].availability == true && vector[i].used == false {
            vector[i].used = true
            return i
        }
    }

    return -1
}
