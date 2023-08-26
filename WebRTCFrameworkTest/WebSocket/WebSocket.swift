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

// MARK: - Native WebSocket
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
        // TODO: by time interval
        // self.socket?.sendPing(pongReceiveHandler: (Error?) -> Void)
    }

    func send(data: Data) {
        self.socket?.send(.data(data)) { _ in }
    }
    
    func send(string: String) {
        self.socket?.send(.string(string)) { _ in }
    }
    
    private func readMessage() {
        self.socket?.receive { [weak self] message in
            guard let self = self else { return }
            
            switch message {
            case .success(.data(let data)):
                self.delegate?.webSocket(self, didReceiveData: data)
                self.readMessage()
            case .success:
                debugPrint("WS: Format mismatch!")
                self.readMessage()
            case .failure:
                self.disconnect()
            }
        }
    }
    
    func disconnect() {
        self.socket?.cancel()
        self.socket = nil
        self.delegate?.webSocketDidDisconnect(self)
    }
}

extension WebSocket: URLSessionWebSocketDelegate, URLSessionDelegate  {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        self.delegate?.webSocketDidConnect(self)
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        self.disconnect()
    }
}
