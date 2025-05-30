//
//  ViewModel.swift
//  SpacePatrol
//
//  Created by Saverio Negro on 04/05/25.
//

import SwiftUI
import FieldKit
import RealityKit

class ViewModel: ObservableObject {
    
    // App and robot assistant state properties
    @Published var appFlowState: AppFlowState = .onPlanet
    @Published var assistantState: AssistantState = .idle
    
    // Vector-Field-Control Related Properties
    @Published var fieldType: FieldType = .radial
    @Published var fieldVolume: Float = 5
    @Published var fieldDensity: VectorDensity = .low
    @Published var isFieldActive: Bool = false
    @Published var duration: TimeInterval = 10
    @Published var magnitude: Float = 5
    
        // Radial-Field Related Properties
        @Published var radialDirection: RadialDirection = .inward
    
        // Spiral-Field Related Properties
        @Published var aboutAxis: RotationAxis = .x
        @Published var rotation: RotationDirection = .clockwise
    
    // Create basketball entity to apply the force field on
    internal func createBasketBall() -> ModelEntity? {
        
        let basketBalllMesh = MeshResource.generateSphere(radius: 0.2)
        
        guard let basketBallTexture = TextureResource.getObjectTexture(named: "BasketBallTexture") else { return nil }
        
        let basketBallEntity = ModelEntity(mesh: basketBalllMesh, materials: [basketBallTexture])
        
        basketBallEntity.components.set(InputTargetComponent())
        basketBallEntity.generateCollisionShapes(recursive: true)
        basketBallEntity.components.set(PhysicsBodyComponent(
            massProperties: .init(mass: 1),
            material: .generate(friction: 0.2, restitution: 1),
            mode: .dynamic
        ))
        
        return basketBallEntity
    }
}
