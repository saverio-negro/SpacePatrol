//
//  ModelEntity-Extension.swift
//  SpacePatrol
//
//  Created by Saverio Negro on 20/05/25.
//

import SwiftUI
import RealityKit

extension ModelEntity {
    func createFingerTip() -> ModelEntity {
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
}
