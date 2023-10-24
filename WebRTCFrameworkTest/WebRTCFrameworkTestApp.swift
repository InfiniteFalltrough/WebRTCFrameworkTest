//
//  WebRTCFrameworkTestApp.swift
//  WebRTCFrameworkTest
//
//  Created by Viktor Golubenkov on 8/22/23.
//

import SwiftUI

@main
struct WebRTCFrameworkTestApp: App {

    @StateObject var hudState = HUDState()
    @StateObject var networkMonitor = ConnectionMonitor()
    @StateObject private var model = WebRTCConnectionModel(
        webRTCClient: WebRTCClient(iceServers: publicStuns),
        signalingClient: Signaling(webSocket: WebSocket(url: signalingURL)))

    var body: some Scene {
        WindowGroup {
            ContentView(model: model)
                .hud(isPresented: $hudState.isPresented) {
                    Label(hudState.title, systemImage: hudState.systemImage)
                }
                .onChange(of: networkMonitor.internetConnectionState) { _ in
                    if !networkMonitor.internetConnectionState {
                        hudState.show(title: "Low connection", systemImage: "exclamationmark.circle")
                    }
                }
        }
    }
}
