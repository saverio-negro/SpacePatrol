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
    
    @EnvironmentObject var viewModel: ViewModel
    
    @State private var robot = Entity()
    @State private var inputText = "This is a test"
    @State private var showTextField = false
    
    @State private var assistantEntity = {
        let anchorEntity = AnchorEntity(.head)
        anchorEntity.position = SIMD3<Float>(0.6, -0.2, -1.0)
        let radians = -30 * Float.pi / 180
        anchorEntity.transform.rotation = simd_quatf(angle: radians, axis: [0, 1, 0])
        return anchorEntity
    }()
    
    var attachment: some View {
        VStack{
            Text(inputText)
                .frame(width: 600, alignment: .leading)
                .font(.extraLargeTitle2)
                .fontWeight(.regular)
                .padding(40)
                .glassBackgroundEffect()
        }
        .opacity(showTextField ? 1 : 0)
        .animation(
            Animation.easeInOut,
            value: showTextField
        )
    }
    
    var body: some View {
        RealityView { content, attachments in
            await generateIntroView(content: content, attachments: attachments)
        } update: { content, attachment in
            
        } attachments: {
            Attachment(id: "attachment") {
                self.attachment
            }
        }
        .gesture(
            TapGesture()
                .targetedToEntity(robot)
                .onEnded { _ in
                    viewModel.assistantState = .greet
                }
        )
        .onChange(of: viewModel.assistantState) { _, newValue in
            switch viewModel.assistantState {
            case .idle:
                break
            case .greet:
                Task {
                    await playIntroSequence()
                }
            case .excited:
                break
            }
        }
    }
    
    private func getNanosecondsFromSeconds(seconds: Double) -> UInt64 {
        return UInt64(seconds * pow(10, 9))
    }
    
    private func animateText(text: String) async {
        inputText = ""
        
        let letters = text.split(separator: "")
        
        for letter in letters {
            let time1 = getNanosecondsFromSeconds(seconds: 0.1)
            let time2 = getNanosecondsFromSeconds(seconds: 0.3)
            let randomDeltaTime = UInt64.random(in: time1...time2)
            try! await Task.sleep(nanoseconds: randomDeltaTime)
            
            inputText += letter
        }
    }
    
    private func showTextAndWaveAnimation() async {
        
        if !showTextField {
            
            showTextField = true
            
            let idleAnimation = robot.availableAnimations[0]
            let victoryAnimation = robot.availableAnimations[2]
            guard let victoryIdleAnimationSequence = try? AnimationResource.sequence(with: [victoryAnimation, idleAnimation.repeat()])
            else {
                return
            }
            
            robot.playAnimation(victoryIdleAnimationSequence)
        }
    }
    
    private func playIntroSequence() async {
        
        // Robot assistant texts
        let texts = [
            "Hello! Are you ready for an exciting adventure in space?",
        ]
        
        async let showTextAndWaveAnimation: Void = showTextAndWaveAnimation()
        async let animateText: Void = animateText(text: texts[0])
        
        _ = await(showTextAndWaveAnimation, animateText)
    }
    
    private func generateIntroView(content: RealityViewContent, attachments: RealityViewAttachments) async {
        
        guard let scene = try? await Entity(named: "Scene", in: realityKitContentBundle) else { return }
        
        // Load in robot assistant and its animations
        guard let robot = scene.findEntity(named: "robot_idle") else { return }
        self.robot = robot
        robot.transform.scale = [0.0025, 0.0025, 0.0025]
        robot.generateCollisionShapes(recursive: true)
        robot.components.set(InputTargetComponent())
        let idleAnimation = robot.availableAnimations[0]
        let waveAnimation = robot.availableAnimations[1]
        
        // Get SwiftUI attachmentsv
        guard
            let attachmentEntity = attachments.entity(for: "attachment")
        else {
            fatalError("Failed to create attachment entity.")
        }
        attachmentEntity.position = SIMD3<Float>(0, 0.55, 0)
        let radians = 30 * Float.pi / 180
        attachmentEntity.transform.rotation = simd_quatf(angle: radians, axis: [0, 1, 0])
        
        // Create sequence animation
        guard
            let waveIdleAnimationSequence = try? AnimationResource.sequence(with: [waveAnimation, idleAnimation.repeat()])
        else {
            return
        }
        
        assistantEntity.addChild(attachmentEntity)
        assistantEntity.addChild(robot)
        content.add(assistantEntity)
        
        robot.playAnimation(idleAnimation.repeat())
    }
}
