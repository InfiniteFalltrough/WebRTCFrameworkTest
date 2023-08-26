//
//  WebRTCViewContainer.swift
//  WebRTCFrameworkTest
//
//  Created by Viktor Golubenkov on 8/24/23.
//

import SwiftUI
import WebRTC

struct WebRTCViewContainer: UIViewRepresentable {
    
    @Binding var videoTrack: RTCVideoTrack?
    
    let contentMode: UIView.ContentMode
    
    func makeUIView(context: Context) -> RTCMTLVideoView {
        let videoView = RTCMTLVideoView()
        videoView.contentMode = contentMode
        return videoView
    }
    
    func updateUIView(_ uiView: RTCMTLVideoView, context: Context) {
        guard let vTrack = videoTrack else {
            return
        }
        vTrack.add(uiView)
    }
}
