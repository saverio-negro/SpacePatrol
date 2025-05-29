//
//  ContentView.swift
//  SpacePatrol
//
//  Created by Saverio Negro on 04/05/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    var introViewText: some View {
        VStack {
            Text("Welcome to Space Patrol!")
                .font(.extraLargeTitle2)
                .padding()
            Text("Hint: Tap onto the robot assistant.")
                .font(.title)
                .padding()
        }
    }
    
    var planetViewText: some View {
        VStack {
            
        }
    }
    
    var body: some View {
        Group {
            switch viewModel.appFlowState {
            case .intro:
                introViewText
            default:
                EmptyView()
                    .disabled(true)
            }
        }
        .padding()
        .task {
            await openImmersiveSpace(id: "ImmersiveSpace")
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
