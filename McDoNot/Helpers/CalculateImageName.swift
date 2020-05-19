//
//  CalculateImageName.swift
//  McDoNot
//
//  Created by Roberto Scarpati on 04/03/2020.
//  Copyright © 2020 McDoNot. All rights reserved.
//

import Foundation

func calculateImageName(name: String, type: String) -> String {
    switch type {
    case NSLocalizedString("Library", comment: "Library"):
        let offset = (name.lengthOfBytes(using: .unicode) % 14) + 1
        return (NSLocalizedString("Library-", comment: "Library-") + String(offset))
    case NSLocalizedString("University", comment: "University"):
        let offset = (name.lengthOfBytes(using: .unicode) % 14) + 1
        return (NSLocalizedString("University-", comment: "University-") + String(offset))
    case NSLocalizedString("Cafè", comment: "Cafè"):
        let offset = (name.lengthOfBytes(using: .unicode) % 14) + 1
        return (NSLocalizedString("Bar-", comment: "Bar-") + String(offset))
    case NSLocalizedString("Bakery", comment: "Bakery"):
        let offset = (name.lengthOfBytes(using: .unicode) % 14) + 1
        return (NSLocalizedString("Bakery-", comment: "Bakery-") + String(offset))
    default:
        let offset = (name.lengthOfBytes(using: .unicode) % 14) + 1
        return (NSLocalizedString("Spot-", comment: "Spot-") + String(offset))
    }
}
