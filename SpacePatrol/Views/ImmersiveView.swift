//
//  ImmersiveView.swift
//  SpacePatrol
//
//  Created by Saverio Negro on 04/05/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    
    @State private var headAnchor = {
        let anchorEntity = AnchorEntity(.head)
        anchorEntity.position = SIMD3<Float>(2.5, -0.5, -4.0)
        return anchorEntity
    }()
    
    var body: some View {
        RealityView { content in
            guard let scene = try? await Entity(named: "Scene", in: realityKitContentBundle) else { return }
            guard let robot = scene.findEntity(named: "robot_idle") else { return }
            let idleAnimation = robot.availableAnimations[0]
            let waveAnimation = robot.availableAnimations[1]
            guard
                let waveIdleAnimationSequence = try? AnimationResource.sequence(with: [waveAnimation, idleAnimation.repeat()])
            else {
                return
            }
            
            robot.playAnimation(idleAnimation.repeat())
            headAnchor.addChild(robot)
            content.add(headAnchor)
        } update: { content in
            
        }
    }
}
