//
//  WebRTCConnectionModel.swift
//  WebRTCFrameworkTest
//
//  Created by Viktor Golubenkov on 8/24/23.
//

import SwiftUI
import WebRTC

@MainActor
class WebRTCConnectionModel: ObservableObject {
    
    private var webRTCClient: WebRTCClient
    private var signalingClient: Signaling
    
    @Published public var signalingConnected: Bool = false
    @Published public var mute: Bool = false
    @Published public var disableVideo: Bool = false
    @Published public var connectionState: RTCIceConnectionState = .checking
    @Published public var localVideoTrack: RTCVideoTrack? = nil
    @Published public var remoteVideoTrack: RTCVideoTrack? = nil
    
    init(webRTCClient: WebRTCClient, signalingClient: Signaling) {
        self.webRTCClient = webRTCClient
        self.signalingClient = signalingClient
        
        localVideoTrack = webRTCClient.localVideoTrack
        remoteVideoTrack = webRTCClient.remoteVideoTrack
        
        self.webRTCClient.delegate = self
        self.signalingClient.delegate = self
    }
    
    public func connect() {
        if !signalingConnected {
            self.signalingClient.connect()
        }
    }
    
    public func makeCall() {
        self.webRTCClient.offer { sdp in
            self.signalingClient.send(sdp: sdp)
        }
    }
    
    public func startCaptureLocalVideo() {
        self.webRTCClient.startCaptureLocalVideo()
    }
    
    public func stopCapturingLocalVideo() {
        self.webRTCClient.stopCaptureLocalVideo()
    }
    
    public func toggleAudio() {
        webRTCClient.enableAudio(mute ? false : true)
        mute.toggle()
    }
    
    public func toggleVideo() {
        webRTCClient.enableVideo(disableVideo ? false : true)
        disableVideo.toggle()
    }
}

// MARK: - Signaling delegate
extension WebRTCConnectionModel: SignalingDelegate {
    
    func signalingClientDidConnect(_ signalClient: Signaling) {
        debugPrint("WebRTCConnectionModel: signaling connected")
        Task {
            self.signalingConnected = true
        }
    }
    
    func signalingClientDidDisconnect(_ signalClient: Signaling) {
        debugPrint("WebRTCConnectionModel: signaling disconnected")
        Task {
            self.signalingConnected = false
        }
    }
    
    func signalingClient(_ signalClient: Signaling, didReceiveRemoteSdp sdp: RTCSessionDescription) {
        debugPrint("WebRTCConnectionModel: didReceiveRemoteSdp")
        self.webRTCClient.set(remoteSdp: sdp) { _ in
            if !sdp.description.isEmpty {
                self.webRTCClient.answer { localSdp in
                    signalClient.send(sdp: localSdp)
                }
            }
        }
    }
    
    func signalingClient(_ signalClient: Signaling, didReceiveCandidate candidate: RTCIceCandidate) {
        self.webRTCClient.set(remoteCandidate: candidate) { _ in
            debugPrint("WebRTCConnectionModel: didReceiveCandidate")
        }
    }
}

// MARK: - WebRTC client delegate
extension WebRTCConnectionModel: WebRTCClientDelegate {
    
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        debugPrint("WebRTCConnectionModel: didDiscoverLocalCandidate")
        self.signalingClient.send(iceCandidate: candidate)
    }
    
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        debugPrint("WebRTCConnectionModel: didChangeConnectionState - \(state)")
        Task {
            self.connectionState = state
        }
    }

    // TODO: Handle data transfer
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data) {
        DispatchQueue.main.async {
            let message = String(data: data, encoding: .utf8) ?? "(Binary: \(data.count) bytes)"
            debugPrint("WebRTCConnectionModel: didReceiveData - \(message)")
        }
    }
}

