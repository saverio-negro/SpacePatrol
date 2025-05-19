//
//  SpacePatrolApp.swift
//  SpacePatrol
//
//  Created by Saverio Negro on 04/05/25.
//

import SwiftUI

@main
struct SpacePatrolApp: App {
    
    @StateObject var viewModel = ViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 200, maxWidth: 600,
                       minHeight: 80, maxHeight: 160
                )
                .glassBackgroundEffect()
        }
        .windowStyle(.plain)
        
        ImmersiveSpace(id: "ImmersiveSpace") {
            switch viewModel.appFlowState {
            case .intro:
                IntroView()
                    .environmentObject(viewModel)
            case .planetSelection:
                PlanetSelectionView()
            case .onPlanet:
                PlanetView()
            }
        }
    }
}
