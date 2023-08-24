//
//  ConnectionMonitor.swift
//  WebRTCFrameworkTest
//
//  Created by Viktor Golubenkov on 8/24/23.
//

import Foundation
import Network

final class ConnectionMonitor: ObservableObject {
    
    let pathMonitor = NWPathMonitor()
    let queue = DispatchQueue(label: "ConnectionMonitor")
    
    @Published var internetConnectionState: Bool = true
    
    init() {
        pathMonitor.pathUpdateHandler = { [weak self] p in
            DispatchQueue.main.async {
                self?.internetConnectionState = p.status == .satisfied ? true : false
            }
        }
        pathMonitor.start(queue: queue)
    }
    
}
