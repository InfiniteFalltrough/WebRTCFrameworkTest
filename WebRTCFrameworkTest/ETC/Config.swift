//
//  Config.swift
//  WebRTCFrameworkTest
//
//  Created by Viktor Golubenkov on 8/24/23.
//

import Foundation

#if targetEnvironment(simulator)
// For simulator
let signalingURL = URL(string: "ws://localhost:8080")!
#else
// For physical device
let signalingURL = URL(string: "ws://192.168.1.102:8080")!
#endif

// Public stuns (Google). Might be slower, but stable.
#if DEBUG
let publicStuns = [
    "stun:stun.l.google.com:19302",
    "stun:stun1.l.google.com:19302",
    "stun:stun2.l.google.com:19302",
    "stun:stun3.l.google.com:19302",
    "stun:stun4.l.google.com:19302",
]
#else
// To increase the speed, build your own specialized stun server.
let privateStun = []
#endif
