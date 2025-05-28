//
//  PlanetView.swift
//  SpacePatrol
//
//  Created by Saverio Negro on 19/05/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct PlanetView: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @StateObject var handTrackingViewModel = HandTrackingViewModel()
    
    var body: some View {
        RealityView { content in
            content.add(handTrackingViewModel.setupContentEntity())
        }
        .task {
            // Run ARKit Session
//            await handTrackingViewModel.runSession()
        }
        .task {
            // Process hand updates
        }
        .gesture(
            SpatialTapGesture().targetedToAnyEntity().onEnded { value in
                
            }
        )
    }
}
