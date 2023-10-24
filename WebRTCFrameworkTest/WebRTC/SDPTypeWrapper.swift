//
//  SDPTypeWrapper.swift
//  WebRTCFrameworkTest
//
//  Created by Viktor Golubenkov on 8/22/23.
//

import Foundation
import WebRTC

enum SDPTypeWrapper: String, Codable {
    case offer, prAnswer, answer, rollback

    var sdpType: RTCSdpType {
        switch self {
        case .offer:    return .offer
        case .answer:   return .answer
        case .prAnswer: return .prAnswer
        case .rollback: return .rollback
        }
    }
}
