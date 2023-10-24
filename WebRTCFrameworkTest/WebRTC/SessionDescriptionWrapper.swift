//
//  SessionDescriptionWrapper.swift
//  WebRTCFrameworkTest
//
//  Created by Viktor Golubenkov on 8/22/23.
//

import Foundation
import WebRTC

struct SessionDescriptionWrapper: Codable {
    let sdp: String
    let sdpType: SDPTypeWrapper

    init(from sessionDescription: RTCSessionDescription) {
        self.sdp = sessionDescription.sdp

        switch sessionDescription.type {
        case .offer:    self.sdpType = .offer
        case .prAnswer: self.sdpType = .prAnswer
        case .answer:   self.sdpType = .answer
        case .rollback: self.sdpType = .rollback
        @unknown default:
            fatalError("Error! Received wrong session description: \(sessionDescription.type.rawValue)")
        }
    }

    var sessionDescription: RTCSessionDescription {
        return RTCSessionDescription(type: self.sdpType.sdpType, sdp: self.sdp)
    }
}
