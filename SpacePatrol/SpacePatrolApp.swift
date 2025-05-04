//
//  SpacePatrolApp.swift
//  SpacePatrol
//
//  Created by Saverio Negro on 04/05/25.
//

import SwiftUI

@main
struct SpacePatrolApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 200, maxWidth: 600,
                       minHeight: 100, maxHeight: 200
                )
                .glassBackgroundEffect()
        }
        .windowStyle(.plain)
        
        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
