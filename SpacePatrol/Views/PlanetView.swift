//
//  PlanetView.swift
//  SpacePatrol
//
//  Created by Saverio Negro on 19/05/25.
//

import SwiftUI
import RealityKit
import RealityKitContent
import Combine

struct PlanetView: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @StateObject var handTrackingViewModel = HandTrackingViewModel()
    @Environment(\.openWindow) var openWindow
    
    @State private var userSelectionPublisher: PassthroughSubject<Void, Never> = PassthroughSubject()
    @State private var userSelectionSubscriber: Cancellable?
    
    @State private var mars = Entity()
    @State private var skybox = Entity()
    @State private var robot = Entity()
    @State private var showRobotMessage = false
    @State private var inputText = ""
    @State private var showButtons = false
    
    var robotMessage: some View {
        VStack {
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
                    showRobotMessage = false
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
        .opacity(showRobotMessage ? 1 : 0)
        .animation(
            Animation.easeInOut,
            value: showRobotMessage
        )
    }
    
    var body: some View {
        RealityView { content, attachments in
            await setupContentAndAttachments(content: content, attachments: attachments)
        } attachments: {
            Attachment(id: "robotMessage") {
                robotMessage
            }
        }
        .gesture(
            TapGesture().targetedToEntity(robot).onEnded { _ in
                viewModel.assistantState = .greet
            }
        )
        .onChange(of: viewModel.assistantState) { _, newValue in
            switch newValue {
            case .idle:
                break
            case .greet:
                Task {
                    await playInfoSequence()
                }
            case .excited:
                Task {
                    await playVictoryAnimation()
                }
            }
        }
    }
}

// MARK: - Set up `RealityViewContent` and `RealityViewAttachments`
extension PlanetView {
    func setupContentAndAttachments(content: RealityViewContent, attachments: RealityViewAttachments) async {
        
        // Load in scene
        guard let scene = try? await Entity(named: "Planet", in: realityKitContentBundle) else { fatalError("Failed loading in the scene.") }
        
        // Load in skybox
        guard let skybox = ModelEntity.generateSkyBox(when: .onPlanet) else { fatalError("Failed loading in the skybox.") }
        self.skybox = skybox
        
        // Load in Mars
        guard let mars = scene.findEntity(named: "Mars") else { fatalError("Failed loading in Mars.") }
        self.mars = mars
        
        // Load in robot assistant and its animations
        
        // Load in robot scene
        guard let robotScene = try? await Entity(named: "RobotOnMars", in: realityKitContentBundle) else { fatalError("Failed loading in the scene.") }
        guard let robot = robotScene.findEntity(named: "robot_idle") else { return }
        self.robot = robot
        robot.transform.scale = [0.0025, 0.0025, 0.0025]
        robot.transform.translation = [0.3, 0.3, -1.5]
        robot.generateCollisionShapes(recursive: true)
        robot.components.set(InputTargetComponent())
        let idleAnimation = robot.availableAnimations[0]
        robot.playAnimation(idleAnimation.repeat())
        
        // Load in robot message attachment and set its transform matrix relative to the robot entity
        guard let attachment = attachments.entity(for: "robotMessage") else { fatalError("Failed loading in attachments") }
        let transformMatrixRelativeToRobot = attachment.transformMatrix(relativeTo: robot)
        let newTransformMatrixRelativeToRobot = float4x4(
            transformMatrixRelativeToRobot.columns.0,
            transformMatrixRelativeToRobot.columns.1,
            transformMatrixRelativeToRobot.columns.2,
            SIMD4<Float>(0, 250, 0, 1)
        )
        attachment.setTransformMatrix(newTransformMatrixRelativeToRobot, relativeTo: robot)
        
        
        content.add(skybox)
        content.add(mars)
        content.add(robot)
        content.add(attachment)
    }
}

// MARK: - Utility functions
extension PlanetView {
    func playInfoSequence() async {
        
        if !showRobotMessage {
            await showTextAndWaveAnimation()
            await Utility.animateText(text: "Hello and welcome to Mars. Play around with the vector field system. Are you ready?", inputText: $inputText)
            
            showButtons = true
            await awaitUserSelection()
            showButtons = false
            
            viewModel.assistantState = .excited
            try! await Task.sleep(nanoseconds: Time.getNanosecondsFromSeconds(seconds: 2))
            inputText = "..."
            openWindow(id: "VectorFieldSystem")
            
        } else {
            await Utility.animateText(text: "Have fun with the Martian vector field system", inputText: $inputText)
            try! await Task.sleep(nanoseconds: Time.getNanosecondsFromSeconds(seconds: 3))
            inputText = "..."
            viewModel.assistantState = .idle
        }
    }
    
    private func showTextAndWaveAnimation() async {
            
            showRobotMessage = true
            
            let idleAnimation = robot.availableAnimations[0]
            let waveAnimation = robot.availableAnimations[1]
            guard
                let waveIdleAnimationSequence = try? AnimationResource.sequence(with: [waveAnimation, idleAnimation.repeat()])
            else {
                return
            }
            
            robot.playAnimation(waveIdleAnimationSequence)
    }
    
    func awaitUserSelection() async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            userSelectionSubscriber = userSelectionPublisher.sink(receiveValue: { _ in
                continuation.resume()
            })
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
}

