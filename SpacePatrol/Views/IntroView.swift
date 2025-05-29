//
//  IntroView.swift
//  SpacePatrol
//
//  Created by Saverio Negro on 04/05/25.
//

import SwiftUI
import RealityKit
import RealityKitContent
import Combine

struct IntroView: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
    @State private var robot = Entity()
    @State private var mars = Entity()
    @State private var inputText = "This is a test"
    @State private var showTextField = false
    @State private var showButtons = false
    
    // Publishers and Subscribers
    @State private var userSelectionPublisher: PassthroughSubject<Void, Never> = PassthroughSubject()
    @State private var rotateMarsPublisher: PassthroughSubject<Void, Never> = PassthroughSubject()
    @State private var userSelectionSubscriber: Cancellable?
    @State private var rotateMarsSubscriber: Cancellable?
    
    @State private var assistantEntity = {
        let anchorEntity = AnchorEntity(.head)
        anchorEntity.position = SIMD3<Float>(0.6, -0.3, -1.0)
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
            
            HStack(spacing: 20) {
                Button {
                    userSelectionPublisher.send()
                } label: {
                    Text("Yes")
                        .font(.extraLargeTitle2)
                        .padding()
                }
                
                Button {
                    showTextField = false
                    viewModel.assistantState = .idle
                } label: {
                    Text("No")
                        .font(.extraLargeTitle2)
                        .padding()
                }
            }
            .opacity(showButtons ? 1 : 0)
            .animation(
                Animation.easeInOut,
                value: showButtons
            )
            
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
                Task {
                    await playVictoryAnimation()
                }
            }
        }
        .task {
            rotateMarsSubscriber = rotateMarsPublisher.sink { _ in
                Task {
                    await mars.rotate(radiansPerSecond: 0.1, axis: .y, while: viewModel.appFlowState == .intro)
                }
            }
        }
    }
}

// MARK: - Utility Methods

extension IntroView {
    private func animateText(text: String) async {
        inputText = ""
        
        let letters = text.split(separator: "")
        
        for letter in letters {
            let time1 = Time.getNanosecondsFromSeconds(seconds: 0.05)
            let time2 = Time.getNanosecondsFromSeconds(seconds: 0.09)
            let randomDeltaTime = UInt64.random(in: time1...time2)
            try! await Task.sleep(nanoseconds: randomDeltaTime)
            
            inputText += letter
        }
    }
    
    private func showTextAndWaveAnimation() async {
        
        if !showTextField {
            
            showTextField = true
            
            let idleAnimation = robot.availableAnimations[0]
            let waveAnimation = robot.availableAnimations[1]
            guard
                let waveIdleAnimationSequence = try? AnimationResource.sequence(with: [waveAnimation, idleAnimation.repeat()])
            else {
                return
            }
            
            robot.playAnimation(waveIdleAnimationSequence)
        }
    }
    
    private func playVictoryAnimation() async {
        let idleAnimation = robot.availableAnimations[0]
        let victoryAnimation = robot.availableAnimations[2]
        
        guard
            let victoryIdleAnimationSequence = try? AnimationResource.sequence(with: [victoryAnimation, idleAnimation.repeat()])
        else {
            return
        }
        
        robot.playAnimation(victoryIdleAnimationSequence)
    }
    
    func awaitUserSelection() async {
        await withCheckedContinuation { (continutation: CheckedContinuation<Void, Never>) in
            userSelectionSubscriber = userSelectionPublisher.sink(receiveValue: { _ in
                continutation.resume()
            })
        }
    }
    
    private func playIntroSequence() async {
        
        // Robot assistant texts
        let texts = [
            "Hello! Are you ready for an exciting adventure in space?",
            "Hurray! Martians are waiting for you!"
        ]
        
        async let showTextAndWaveAnimation: Void = showTextAndWaveAnimation()
        async let animateText: Void = animateText(text: texts[0])
        
        _ = await(showTextAndWaveAnimation, animateText)
        
        showButtons = true
        await awaitUserSelection()
        showButtons = false
        
        viewModel.assistantState = .excited
        await self.animateText(text: texts[1])
        
        withAnimation(Animation.easeInOut(duration: 1)) {
            viewModel.assistantState = .idle
            viewModel.appFlowState = .onSpaceship
        }
    }
}


// MARK: - RealityContentView and RealityViewAttachments Setup

extension IntroView {
    private func generateIntroView(content: RealityViewContent, attachments: RealityViewAttachments) async {
        
        guard let scene = try? await Entity(named: "Scene", in: realityKitContentBundle) else { return }
        
        // Load in robot assistant and its animations
        guard let robot = scene.findEntity(named: "robot_idle") else { return }
        self.robot = robot
        robot.transform.scale = [0.0025, 0.0025, 0.0025]
        robot.generateCollisionShapes(recursive: true)
        robot.components.set(InputTargetComponent())
        
        // Load in mars and rotate it
        guard let mars = robot.findEntity(named: "Mars") else { return }
        mars.components.remove(InputTargetComponent.self)
        mars.components.remove(CollisionComponent.self)
        self.mars = mars
        rotateMarsPublisher.send()
        
        
        let idleAnimation = robot.availableAnimations[0]
        
        // Get SwiftUI attachments
        guard
            let attachmentEntity = attachments.entity(for: "attachment")
        else {
            fatalError("Failed to create attachment entity.")
        }
        attachmentEntity.position = SIMD3<Float>(0, 0.60, 0)
        let radians = 30 * Float.pi / 180
        attachmentEntity.transform.rotation = simd_quatf(angle: radians, axis: [0, 1, 0])
        
        assistantEntity.addChild(attachmentEntity)
        assistantEntity.addChild(robot)
        content.add(assistantEntity)
        
        robot.playAnimation(idleAnimation.repeat())
    }
}
