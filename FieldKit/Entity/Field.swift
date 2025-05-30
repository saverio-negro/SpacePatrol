//
//  Field.swift
//  FieldKit
//
//  Created by Saverio Negro on 08/05/25.
//

import Foundation
import RealityKit
import _RealityKit_SwiftUI
import Combine

// Class representing the field
public class Field {
    
    public let content: RealityViewContent
    public var area: FieldAreaComponent?
    public var trait: FieldTraitComponent?
    private var referenceEntity: Entity?
    private var center: SIMD3<Float> {
        
        if let referenceEntity = referenceEntity {
            let entityTransformMatrix = referenceEntity.transform.matrix
            let entityPositionVector = SIMD4<Float>.mapToSIMD3(entityTransformMatrix * [0, 0, 0, 1])
            return entityPositionVector
        }
        
        return SIMD3<Float>.zero
    }
    public var eventUpdateSubscription: EventSubscription?
    
    public init(content: RealityViewContent, area: FieldAreaComponent? = nil, trait: FieldTraitComponent? = nil, relativeTo referenceEntity: Entity? = nil) {
        self.content = content
        self.area = area
        self.trait = trait
        self.referenceEntity = referenceEntity
    }
    
    private func getTransformedVector(_ vector: SIMD3<Float>) -> SIMD3<Float> {
        if let referenceEntity = referenceEntity {
            let entityTransformMatrix = referenceEntity.transform.matrix
            let vector4 = SIMD3<Float>.mapToSIMD4(vector)
            let transformedVector = entityTransformMatrix * vector4
            return SIMD4<Float>.mapToSIMD3(transformedVector)
        }
        return vector
    }
    
    private func getTransformedPositionVector(_ vector: SIMD3<Float>) -> SIMD3<Float> {
        if let referenceEntity = referenceEntity {
            let entityTransformMatrix = referenceEntity.transform.matrix
            let referenceEntityVectorPosition4 = entityTransformMatrix * [0, 0, 0, 1]
            let referenceEntityVectorPosition = SIMD4<Float>.mapToSIMD3(referenceEntityVectorPosition4)
            
            // Get the vector position starting from the origin of the coordinate space of the entity
            let vectorFromReferenceEntity = vector - referenceEntityVectorPosition
            
            // Get the vector with respect to the frame of reference of the entity
            return getTransformedVector(vectorFromReferenceEntity)
        }
        return vector
    }
    
    private func discretizedArea(vectorDensity: VectorDensity) async -> Array<SIMD3<Float>> {
        guard let area = area else { return [center] }
        
        var discreteVectorArray = Array<SIMD3<Float>>([])
        
        let width = area.width ?? 0
        let height = area.height ?? 0
        let depth = area.depth ?? 0
        
        let xValues = stride(from: -(width/2), through: width/2, by: vectorDensity.stepover)
        let yValues = stride(from: -(height/2), through: height/2, by: vectorDensity.stepover)
        let zValues = stride(from: -(depth/2), through: depth/2, by: vectorDensity.stepover)
        
        // Create the discretized area as a cube of points
        for x in xValues {
            for y in yValues {
                for z in zValues {
                    let fieldPoint = SIMD3<Float>(x, y, z)
                    let transformedFieldPoint = getTransformedVector(fieldPoint)
                    let vectorPosition = center + transformedFieldPoint
                    discreteVectorArray.append(vectorPosition)
                }
            }
        }
        return discreteVectorArray
    }
    
    private func force(at vectorPosition: SIMD3<Float>, time: TimeInterval) -> SIMD3<Float> {
        if let fieldTrait = trait?.fieldTrait {
            // Define force depending on the trait of the field
            switch fieldTrait {
            case .radial(let direction, let magnitude):
                let magnitude = magnitude(vectorPosition, time)
                let radialFieldSystem = RadialFieldSystem(
                    inOutDirection: direction,
                    magnitude: magnitude,
                    vectorPosition: vectorPosition
                )
                return radialFieldSystem.vectorField
            case .spiral(let aboutAxis, let rotation, let magnitude):
                let magnitude = magnitude(vectorPosition, time)
                let spiralFieldSystem = SpiralFieldSystem(
                    aboutAxis: aboutAxis,
                    rotation: rotation,
                    magnitude: magnitude,
                    vectorPosition: vectorPosition
                )
                return spiralFieldSystem.vectorField
            case .custom(let fieldFunction):
                let vectorField = fieldFunction(vectorPosition, time)
                let customFieldSystem = CustomFieldSystem(vectorField: vectorField)
                return customFieldSystem.vectorField
            }
        } else {
            return SIMD3<Float>(0, 0, 0)
        }
    }
    
    private func materializeFieldVector(vector: SIMD3<Float>, at position: SIMD3<Float>) -> ModelEntity {
        let r = vector.length()
        let vectorMesh = MeshResource.generateCylinder(height: r/2, radius: 0.01)
        let vectorMaterial = SimpleMaterial(color: .blue, roughness: 0.5, isMetallic: false)
        let materializedVector = ModelEntity(mesh: vectorMesh, materials: [vectorMaterial])
        materializedVector.transform.rotation = .init(vector: SIMD3<Float>.mapToSIMD4(vector))
        materializedVector.transform.translation = position
        return materializedVector
    }
    
    public func addForceField(vectorDensity: VectorDensity, duration: TimeInterval?, on entity: ModelEntity) async {
        let discreteVectorArray = await self.discretizedArea(vectorDensity: vectorDensity)
        
        RunLoop.main.schedule(after: .init(.init(timeIntervalSinceNow: duration ?? .infinity))) {
            self.eventUpdateSubscription?.cancel()
        }
        
        // Spawn the field every current scene's frame by subscribing to the `SceneEvents.Update` event
        // — from the `RealityViewContent` object — of the scene the `RealityView` is loaded in — typically,
        // your `ImmersiveSpace` scene.
        var timeElapsed: TimeInterval = .zero
        var timeBuffer: TimeInterval = .zero
        let customDeltaTime: TimeInterval = 0.3
        
        eventUpdateSubscription = content.subscribe(to: SceneEvents.Update.self) { event in
            
            if timeBuffer > customDeltaTime {
                for vectorPosition in discreteVectorArray {
                    let force = self.force(at: vectorPosition, time: timeElapsed) * Float(customDeltaTime)
                    let materializedForce = self.materializeFieldVector(vector: force, at: vectorPosition)
                    
                    // Print force information onto the console
                    print("Materialized force (\(force.x), \(force.y), \(force.z)) at (\(vectorPosition.x), \(vectorPosition.y), \(vectorPosition.z))")
                    self.content.add(materializedForce)
                    
                    Task {
                        await entity.addForce(force, at: vectorPosition, relativeTo: nil)
                    }
                }
                timeBuffer = .zero
            }
            
            timeElapsed += event.deltaTime
            timeBuffer += event.deltaTime
        }
    }
}
