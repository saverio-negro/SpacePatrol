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
        
        var skyboxMaterial: UnlitMaterial?
        
        switch event {
        case .intro:
            break
        case .planetTravel:
            fallthrough
        case .onSpaceship:
            fallthrough
        case .onPlanet:
            guard
                let material = TextureResource.getTextureForSkyBox(from: "Space")
            else {
                return nil
            }
            skyboxMaterial = material
        }
        
        guard let material = skyboxMaterial else { return nil }
        skybox.model?.materials = [material]
        
        // Reverse sphere
        skybox.transform.scale = [-1.0, 1.0, 1.0]
        
        return skybox
    }
}
