//
//  ConnectionManager.swift
//  McDoNot
//
//  Created by Roberto Scarpati on 20/02/2020.
//  Copyright © 2020 McDoNot. All rights reserved.
//

import Foundation
import Network

class ConnectionManager {
    static let shared = ConnectionManager()

    private init() {
        monitor.start(queue: queue)
    }

    let monitor = NWPathMonitor()

    let queue = DispatchQueue(label: "Monitor")

    func checkForConnection(completionHandler: @escaping (Bool) -> Void) {
        var isConnected: Bool?
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                isConnected = true
            } else {
                isConnected = false
            }

            completionHandler(isConnected!)
        }

//        if isConnected == nil {
//            return false
//        } else {
//            return isConnected!
//        }
    }
}
