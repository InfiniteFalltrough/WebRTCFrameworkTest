//
//  IceCandidateWrapper.swift
//  WebRTCFrameworkTest
//
//  Created by Viktor Golubenkov on 8/22/23.
//

import Foundation
import WebRTC

struct IceCandidateWrapper: Codable {
    let sdp: String
    let sdpMLineIndex: Int32
    let sdpMid: String?

    init(from iceCandidate: RTCIceCandidate) {
        self.sdpMLineIndex = iceCandidate.sdpMLineIndex
        self.sdpMid = iceCandidate.sdpMid
        self.sdp = iceCandidate.sdp
    }

    var rtcIceCandidate: RTCIceCandidate {
        return RTCIceCandidate(sdp: self.sdp, sdpMLineIndex: self.sdpMLineIndex, sdpMid: self.sdpMid)
    }
}
