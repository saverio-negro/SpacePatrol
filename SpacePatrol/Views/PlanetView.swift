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
import FieldKit

struct PlanetView: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @StateObject var handTrackingViewModel = HandTrackingViewModel()
    
    @State private var userSelectionPublisher: PassthroughSubject<Void, Never> = PassthroughSubject()
    @State private var userSelectionSubscriber: Cancellable?
    
    @State private var vectorFieldControlsPublisher: PassthroughSubject<Void, Never> = PassthroughSubject()
    @State private var vectorFieldControlsSubscriber: Cancellable?
    
    @State private var vectorFieldPublisher: PassthroughSubject<Void, Never> = PassthroughSubject()
    @State private var vectorFieldSubscriber: Cancellable?
    
    @State private var mars = Entity()
    @State private var skybox = Entity()
    @State private var robot = Entity()
    @State private var cube = ModelEntity()
    @State private var showRobotMessage = false
    @State private var inputText = ""
    @State private var showButtons = false
    
    let headAnchorAttachment = {
        let anchorEntity = AnchorEntity(.head)
        anchorEntity.position = [-0.4, 0, -1.0]
        let radians = 10 * Float.pi / 180
        anchorEntity.transform.rotation = simd_quatf(angle: radians, axis: [0, 1, 0])
        
        return anchorEntity
    }()
    
    let sphere = {
        // Generate Box Entity
        let sphere = ModelEntity(
            mesh: .generateSphere(radius: 0.1),
            materials: [SimpleMaterial(color: .blue, roughness: 0.3, isMetallic: false)]
        )
        
        sphere.generateCollisionShapes(recursive: true)
        sphere.components.set(InputTargetComponent(allowedInputTypes: [.direct, .indirect]))
        sphere.components.set(
                PhysicsBodyComponent(
                    massProperties: .init(mass: 2),
                material: .generate(friction: 0.2, restitution: 0.3),
                mode: .dynamic
            )
        )
        sphere.components.set(HoverEffectComponent())
        
        sphere.name = "Box"
        sphere.position = [0, 1.2, -2.0]
        return sphere
    }()
    
    var robotMessage: some View {
        VStack {
            Text(inputText)
                .frame(width: 600, alignment: .leading)
                .font(.extraLargeTitle)
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
    
    var vectorFieldControls: some View {
        VectorFieldControlsView(
            fieldType: $viewModel.fieldType,
            fieldVolume: $viewModel.fieldVolume,
            fieldDensity: $viewModel.fieldDensity,
            isFieldActive: $viewModel.isFieldActive,
            radialDirection: $viewModel.radialDirection,
            aboutAxis: $viewModel.aboutAxis,
            rotation: $viewModel.rotation,
            duration: $viewModel.duration,
            magnitude: $viewModel.magnitude
        ) {
            // Perform action upon toggling button control
            vectorFieldPublisher.send()
        }
    }
    
    var body: some View {
        RealityView { content, attachments in
            await setupContentAndAttachments(content: content, attachments: attachments)
        } attachments: {
            Attachment(id: "robotMessage") {
                robotMessage
            }
            
            Attachment(id: "vectorFieldControls") {
                vectorFieldControls
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
        
        // Load in robot assistant and its animations
        // Load in robot scene
        guard let robotScene = try? await Entity(named: "RobotOnMars", in: realityKitContentBundle) else { fatalError("Failed loading in the scene.") }
        guard let robot = robotScene.findEntity(named: "robot_idle") else { return }
        self.robot = robot
        robot.transform.scale = [0.0025, 0.0025, 0.0025]
        robot.transform.translation = [0.8, 0.3, -1.3]
        robot.transform.rotation = simd_quatf(angle: Float(Angle(degrees: -20).radians), axis: [0, 1, 0])
        robot.generateCollisionShapes(recursive: true)
        robot.components.set(InputTargetComponent())
        let idleAnimation = robot.availableAnimations[0]
        robot.playAnimation(idleAnimation.repeat())
        
        // Load in robot message attachment and set its transform matrix relative to the robot entity
        guard let robotMessageAttachment = attachments.entity(for: "robotMessage") else { fatalError("Failed loading in attachments") }
        let transformMatrixRelativeToRobot = robotMessageAttachment.transformMatrix(relativeTo: robot)
        let newTransformMatrixRelativeToRobot = float4x4(
            transformMatrixRelativeToRobot.columns.0,
            transformMatrixRelativeToRobot.columns.1,
            transformMatrixRelativeToRobot.columns.2,
            SIMD4<Float>(0, 250, 0, 1)
        )
        robotMessageAttachment.setTransformMatrix(newTransformMatrixRelativeToRobot, relativeTo: robot)
        
        // Load in vector field controls
        guard let vectorFieldControlsAttachment = attachments.entity(for: "vectorFieldControls") else { fatalError("Failed loading in attachments") }
        headAnchorAttachment.addChild(vectorFieldControlsAttachment)
        
        vectorFieldControlsSubscriber = vectorFieldControlsPublisher.sink { _ in
            content.add(headAnchorAttachment)
        }
        
        content.add(skybox)
        content.add(scene)
        content.add(sphere)
        content.add(robot)
        content.add(robotMessageAttachment)
        
        // Load in vector Field
        vectorFieldSubscriber = vectorFieldPublisher.sink { _ in
            
            // Create `FieldTraitComponent` object
            let fieldTraitComponent = FieldTraitComponent(
                fieldTrait:
                {
                    switch viewModel.fieldType {
                    case .radial:
                        FieldTrait.radial(direction: viewModel.radialDirection) { vectorPosition, time in
                            viewModel.magnitude
                        }
                    case .spiral:
                        FieldTrait.spiral(aboutAxis: viewModel.aboutAxis, rotation: viewModel.rotation) { vectorPosition, time in
                            viewModel.magnitude
                        }
                    }
                }()
            )
            
            // Create `FieldAreaComponent` object
            let fieldAreaComponent = FieldAreaComponent(
                width: viewModel.fieldVolume,
                height: viewModel.fieldVolume,
                depth: viewModel.fieldVolume
            )
            
            // Spawn vector field
            let field = Field(content: content, area: fieldAreaComponent, trait: fieldTraitComponent, relativeTo: nil)
            field.eventUpdateSubscription?.cancel()
            
            if viewModel.isFieldActive {
                Task {
                    sphere.position = [0, 0.2, -1.0]
                    
                    await field.addForceField(
                        vectorDensity: viewModel.fieldDensity,
                        duration: viewModel.duration,
                        on: sphere
                    )
                }
            } else {
                Task {
                    content.entities.removeAll()
                    await setupContentAndAttachments(content: content, attachments: attachments)
                    sphere.position = [0, 0.2, -1.0]
                    vectorFieldControlsPublisher.send()
                }
            }
        }
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
            vectorFieldControlsPublisher.send()
            
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

