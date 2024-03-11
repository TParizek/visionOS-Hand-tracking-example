//
//  HandTrackingApp.swift
//  HandTracking
//
//  Created by Tomáš Pařízek on 11.03.2024.
//

import SwiftUI

@main
struct HandTrackingApp: App {
    
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    @State private var immersiveSpaceOpened = false

    var body: some Scene {
        WindowGroup {
            Button(immersiveSpaceOpened ? "Stop" : "Start") {
                Task {
                    if immersiveSpaceOpened {
                        await dismissImmersiveSpace()
                    } else {
                        await openImmersiveSpace(id: "world_view")
                    }
                    immersiveSpaceOpened.toggle()
                }
            }
        }
        .windowStyle(.plain)
        .windowResizability(.contentSize)

        ImmersiveSpace(id: "world_view") {
            WorldView()
        }
    }
}
