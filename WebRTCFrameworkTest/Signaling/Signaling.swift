//
//  Signaling.swift
//  WebRTCFrameworkTest
//
//  Created by Viktor Golubenkov on 8/22/23.
//

import Foundation
import WebRTC

protocol SignalingDelegate: AnyObject {
    func signalClientDidConnect(_ signalClient: Signaling)
    func signalClientDidDisconnect(_ signalClient: Signaling)
    func signalClient(_ signalClient: Signaling, didReceiveRemoteSdp sdp: RTCSessionDescription)
    func signalClient(_ signalClient: Signaling, didReceiveCandidate candidate: RTCIceCandidate)
}

final class Signaling {
    
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let webSocket: WebSocket
    weak var delegate: SignalingDelegate?
    
    init(webSocket: WebSocket) {
        self.webSocket = webSocket
    }
    
    func connect() {
        self.webSocket.delegate = self
        self.webSocket.connect()
    }
    
    func send(sdp: RTCSessionDescription) {
        let rtcMessage = WebRTCMessage.sdp(SessionDescriptionWrapper(from: sdp))
        do {
            let message = try self.encoder.encode(rtcMessage)
            
            self.webSocket.send(data: message)
        }
        catch {
            debugPrint("Signaling error! \n Encoding SDP \n \(error.localizedDescription)")
        }
    }
    
    func send(iceCandidate: RTCIceCandidate) {
        let rtcMessage = WebRTCMessage.candidate(IceCandidateWrapper(from: iceCandidate))
        do {
            let message = try self.encoder.encode(rtcMessage)
            self.webSocket.send(data: message)
        }
        catch {
            debugPrint("Signaling error! \n Encoding candidate \n \(error.localizedDescription)")
        }
    }
}


extension Signaling: WebSocketDelegate {
    func webSocketDidConnect(_ webSocket: WebSocket) {
        self.delegate?.signalClientDidConnect(self)
    }
    
    func webSocketDidDisconnect(_ webSocket: WebSocket) {
        self.delegate?.signalClientDidDisconnect(self)
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            self.webSocket.connect()
        }
    }
    
    func webSocket(_ webSocket: WebSocket, didReceiveData data: Data) {
        let message: WebRTCMessage
        do {
            message = try self.decoder.decode(WebRTCMessage.self, from: data)
        }
        catch {
            fatalError("WS Error! \n Could not decode incoming message: \(error.localizedDescription)")
        }
        
        switch message {
        case .candidate(let iceCandidate):
            self.delegate?.signalClient(self, didReceiveCandidate: iceCandidate.rtcIceCandidate)
        case .sdp(let sessionDescription):
            self.delegate?.signalClient(self, didReceiveRemoteSdp: sessionDescription.sessionDescription)
        }
        
    }
}
