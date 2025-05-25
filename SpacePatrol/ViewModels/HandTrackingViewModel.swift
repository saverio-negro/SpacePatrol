//
//  HandTrackingViewModel.swift
//  SpacePatrol
//
//  Created by Saverio Negro on 20/05/25.
//

import SwiftUI
import RealityKit
import ARKit

@MainActor
class HandTrackingViewModel: ObservableObject {
    private let session = ARKitSession()
    private let handTrackingProvider = HandTrackingProvider()
    
    /// A collection entity to receive all the entities, created from this class, which we are meaning
    /// to show in our RealityView.
    /// This collection entity will serve us as a container to fill our `RealityViewContent` object passed
    /// into the `RealityView` constructor
    private var contentEntity = Entity()
    
    // A dictionary to keep track of our finger tip entities based on hand chirality
    private let fingerTipEntities: [HandAnchor.Chirality : ModelEntity] = [
        .left: .createFingerTip(),
        .right: .createFingerTip()
    ]
    
    // Keep track of time for last cube placement. That will serve as a reference to
    // ensure the user is allowed to add additional cubes at a certain cadence.
    private var lastCubePlacementTime: TimeInterval = 0
    
    // Instance method to be used into the RealityView's closure to fill in the RealityViewContent
    // with entities related to this class (e.g., finger tip entities).
    internal func setupContentEntity() -> Entity {
        for entity in fingerTipEntities.values {
            contentEntity.addChild(entity)
        }
        
        return contentEntity
    }
    
    // Initiate ARKit session
    func runSession() async {
        do {
            try await session.run([handTrackingProvider])
        } catch {
            fatalError("Failed running the ARKit session: \(error.localizedDescription)")
        }
    }
    
    // Process hand updates
    func processHandUpdates() async {
        for await anchorUpdate in handTrackingProvider.anchorUpdates {
            let handAnchor = anchorUpdate.anchor
            
            guard handAnchor.isTracked else { continue }
            
            guard let fingerTip = handAnchor.handSkeleton?.joint(.indexFingerTip) else { continue }
            
            if fingerTip.isTracked {
                let originFromWrist = handAnchor.originFromAnchorTransform
                let wristFromIndex = fingerTip.anchorFromJointTransform
                
                let originFromIndex = wristFromIndex * originFromWrist
            }
        }
    }
}
