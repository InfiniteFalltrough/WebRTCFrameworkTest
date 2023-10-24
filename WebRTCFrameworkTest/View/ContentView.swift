//
//  ContentView.swift
//  WebRTCFrameworkTest
//
//  Created by Viktor Golubenkov on 8/22/23.
//

import SwiftUI
import WebRTC

struct ContentView: View {
    @ObservedObject var model: WebRTCConnectionModel
    var body: some View {
        VStack(spacing: 10) {
            statusBar()
            Spacer()
            if model.connectionState == RTCIceConnectionState.connected {
                ZStack(alignment: .topTrailing) {
                    WebRTCViewContainer(videoTrack: $model.remoteVideoTrack, contentMode: .scaleAspectFill)
                        .cornerRadius(8)
                    WebRTCViewContainer(videoTrack: $model.localVideoTrack, contentMode: .scaleAspectFill)
                        .frame(width: 125, height: 125)
                        .cornerRadius(8)
                        .padding()
                }
                controlButtons()
            } else {
                Button {
                    model.makeCall()
                    model.startCaptureLocalVideo()
                } label: {
                    Image(systemName: "phone.fill")
                }
                .font(.largeTitle)
                .foregroundColor(.green)
            }
        }
        .padding()
        .onAppear {
            model.connect()
        }
    }

    func statusBar() -> some View {
        return HStack(spacing: 20) {
            Text(model.signalingConnected ? "Connected" : "Not connected")
                .foregroundColor(model.signalingConnected ? .green : .red)
            Spacer()
            Text("WebRTC: \(model.connectionState.description)")
        }.font(.system(size: 20, weight: .medium))
    }

    func controlButtons() -> some View {
        return HStack(spacing: 40) {
            Spacer()
            Button {
                model.toggleVideo()
            } label: {
                Image(systemName: "camera.fill")
            }.foregroundColor(model.disableVideo ? .green : .red)
            Button {
                model.toggleAudio()
            } label: {
                Image(systemName: "mic.fill")
            }.foregroundColor(model.mute ? .green : .red)
            Button {
            // - todo hang up
            } label: {
                Image(systemName: "phone.fill")
            }.foregroundColor(.red)
            Spacer()
        }.font(.largeTitle)
    }
}
