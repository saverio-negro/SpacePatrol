//
//  ModelEntity-Extension.swift
//  SpacePatrol
//
//  Created by Saverio Negro on 20/05/25.
//

import SwiftUI
import RealityKit

extension ModelEntity {
    
    static func createFingerTip() -> ModelEntity {
        let fingerTipEntity = ModelEntity(
            mesh: .generateSphere(radius: 0.01),
            materials: [UnlitMaterial(color: .gray)],
            collisionShape: .generateSphere(radius: 0.005),
            mass: 0.0
        )
        
        fingerTipEntity.components.set(PhysicsBodyComponent(mode: .kinematic))
        fingerTipEntity.components.set(OpacityComponent(opacity: 1.0))
        
        return fingerTipEntity
    }
    
    static func generateSkyBox(when event: AppFlowState) -> ModelEntity? {
        let skybox = ModelEntity(
            mesh: .generateSphere(radius: 30000000)
        )
        
        var material: UnlitMaterial? = UnlitMaterial()
        
        switch event {
        case .intro:
            break
        case .planetTravel:
            break
        case .onSpaceship:
            fallthrough
        case .onPlanet:
            material = TextureResource.getTextureForSkyBox(from: "Space") ?? nil
        }
        
        guard let material = material else { return nil }
        skybox.model?.materials = [material]
        
        // Reverse sphere
        skybox.transform.scale = [-1.0, 1.0, 1.0]
        
        return skybox
    }
}
