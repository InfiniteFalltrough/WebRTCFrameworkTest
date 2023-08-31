//
//  WebSocket.swift
//  WebRTCFrameworkTest
//
//  Created by Viktor Golubenkov on 8/22/23.
//

import Foundation

protocol WebSocketDelegate: AnyObject {
    func webSocketDidConnect(_ webSocket: WebSocket)
    func webSocketDidDisconnect(_ webSocket: WebSocket)
    func webSocket(_ webSocket: WebSocket, didReceiveData data: Data)
}

class WebSocket: NSObject {
    
    weak var delegate: WebSocketDelegate?
    private let url: URL
    private var socket: URLSessionWebSocketTask?
    private lazy var urlSession: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)

    init(url: URL) {
        self.url = url
        super.init()
    }

    func connect() {
        let socket = urlSession.webSocketTask(with: url)
        socket.resume()
        self.socket = socket
        self.readMessage()
    }

    func send(data: Data) {
        self.socket?.send(.data(data)) { _ in }
    }
    
    private func readMessage() {
        self.socket?.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    self.delegate?.webSocket(self, didReceiveData: data)
                    self.readMessage()
                default:
                    debugPrint("WS: Expected to receive data format but received a string. Check the websocket server config.")
                    self.readMessage()
                }
            case .failure(let error):
                debugPrint("WS: Receive error - \(error)")
                self.disconnect()
            }
        }
    }
    
    func disconnect() {
        self.socket?.cancel(with: .normalClosure, reason: nil)
        self.socket = nil
        self.delegate?.webSocketDidDisconnect(self)
    }
}

extension WebSocket: URLSessionWebSocketDelegate, URLSessionDelegate  {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        self.delegate?.webSocketDidConnect(self)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            debugPrint("WS: URLSession error - \(error)")
            self.disconnect()
        }
    }
}
