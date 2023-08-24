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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .hud(isPresented: $hudState.isPresented) {
                    Label(hudState.title, systemImage: hudState.systemImage)
                }
                .onChange(of: networkMonitor.internetConnectionState) { newValue in
                    if !networkMonitor.internetConnectionState {
                        hudState.show(title: "Low connection", systemImage: "exclamationmark.circle")
                    }
                }
        }
    }
}
