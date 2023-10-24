//
//  CustomHUD.swift
//  WebRTCFrameworkTest
//
//  Created by Viktor Golubenkov on 8/24/23.
//

import SwiftUI

final class HUDState: ObservableObject {

    @Published var isPresented: Bool = false

    private(set) var title: String = ""
    private(set) var systemImage: String = ""

    func show(title: String, systemImage: String) {
        self.title = title
        self.systemImage = systemImage
        withAnimation {
            isPresented = true
        }
    }
}

struct HUD<Content: View>: View {

    @ViewBuilder let content: Content
    @Environment(\.colorScheme) var currentScheme

    var body: some View {
        content
            .foregroundColor(currentScheme == .light ? .white : .black)
            .padding(.horizontal, 6)
            .padding(12)
            .background(
                Capsule()
                    .foregroundColor(currentScheme == .light ? .black : .white)
                    .shadow(
                        color: (currentScheme == .light ? Color.black : Color.white).opacity(0.16),
                        radius: 12, x: 0, y: 5)
            )
    }
}

extension View {

    func hud<Content: View> (
        isPresented: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        ZStack(alignment: .top) { self
            if isPresented.wrappedValue {
                HUD(content: content)
                    .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                isPresented.wrappedValue = false
                            }
                        }
                    }
                    .zIndex(1)
            }
        }
    }
}
