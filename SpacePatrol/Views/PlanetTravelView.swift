//
//  PlanetTravelView.swift
//  SpacePatrol
//
//  Created by Saverio Negro on 25/05/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct PlanetTravelView: View {
    var body: some View {
        RealityView { content in
            guard let skybox = ModelEntity.generateSkyBox(when: .planetTravel) else { return }
            content.add(skybox)
        }
    }
}
