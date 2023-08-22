//
//  WebRTCMessage.swift
//  WebRTCFrameworkTest
//
//  Created by Viktor Golubenkov on 8/22/23.
//

import Foundation

enum WebRTCMessage {
    case sdp(SessionDescriptionWrapper)
    case candidate(IceCandidateWrapper)
}

enum CodingKeys: String, CodingKey {
    case type, payload
}


extension WebRTCMessage: Codable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case String(describing: SessionDescriptionWrapper.self):
            self = .sdp(try container.decode(SessionDescriptionWrapper.self, forKey: .payload))
        case String(describing: IceCandidateWrapper.self):
            self = .candidate(try container.decode(IceCandidateWrapper.self, forKey: .payload))
        default:
            fatalError("Error decoding WebRTC message!")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .sdp(let sessionDescription):
            try container.encode(sessionDescription, forKey: .payload)
            try container.encode(String(describing: SessionDescriptionWrapper.self), forKey: .type)
        case .candidate(let iceCandidate):
            try container.encode(iceCandidate, forKey: .payload)
            try container.encode(String(describing: IceCandidateWrapper.self), forKey: .type)
        }
    }
}
