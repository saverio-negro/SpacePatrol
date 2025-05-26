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
    @State private var immersionStyle: ImmersionStyle = .mixed

    var body: some Scene {
        
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .frame(minWidth: 200, maxWidth: 600,
                       minHeight: 80, maxHeight: 160
                )
                .glassBackgroundEffect()
                .opacity(viewModel.appFlowState == .onSpaceship || viewModel.appFlowState == .planetTravel ? 0 : 1)
        }
        .windowStyle(.plain)
        
        ImmersiveSpace(id: "ImmersiveSpace") {
            switch viewModel.appFlowState {
            case .intro:
                IntroView()
                    .environmentObject(viewModel)
            case .onSpaceship:
                SpaceshipView()
                    .environmentObject(viewModel)
            case .planetTravel:
                PlanetTravelView()
                    .environmentObject(viewModel)
            case .onPlanet:
                PlanetView()
                    .environmentObject(viewModel)
            }
        }
        .immersionStyle(selection: $immersionStyle, in: .mixed, .progressive, .full)
        .onChange(of: viewModel.appFlowState) { _, newValue in
            switch newValue {
            case .intro:
                immersionStyle = .mixed
            case .onSpaceship:
                immersionStyle = .full
            case .planetTravel:
                immersionStyle = .full
            case .onPlanet:
                immersionStyle = .full
            }
        }
    }
}
