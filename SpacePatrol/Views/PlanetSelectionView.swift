//
//  PlanetSelectionView.swift
//  SpacePatrol
//
//  Created by Saverio Negro on 19/05/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct PlanetSelectionView: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        EmptyView()
    }
    
    func generateSkyBox() -> ModelEntity {
        let sphere = ModelEntity(
            mesh: .generateSphere(radius: 2000)
        )
        
        let imageTexture = 
    }
}
