//
//  SpaceshipView.swift
//  SpacePatrol
//
//  Created by Saverio Negro on 19/05/25.
//

import SwiftUI
import RealityKit
import RealityKitContent
import Combine

struct SpaceshipView: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @State private var rotateEarthPublisher: PassthroughSubject<Void, Never> = PassthroughSubject()
    @State private var rotateEarthSubscriber: Cancellable?
    @State private var rotateMoonPublisher: PassthroughSubject<Void, Never> = PassthroughSubject()
    @State private var rotateMoonSubscriber: Cancellable?

    let headAnchor = {
        let anchorEntity = AnchorEntity(.head)
        anchorEntity.position = SIMD3<Float>(0, -1.2, -0.5)
        
        return anchorEntity
    }()
    
    let headAnchorAttachment = {
        let anchorEntity = AnchorEntity(.head)
        anchorEntity.position = SIMD3<Float>(0.5, 0, -0.8)
        
        return anchorEntity
    }()
    @State private var spaceship = Entity()
    @State private var earth = Entity()
    @State private var moon = Entity()
    @State private var sun = Entity()
    @State private var buttonAttachmentEntity = ViewAttachmentEntity()
    @GestureState private var isButtonHeld = false
    
    private var attachment: some View {
        Text("Long press to start up the spaceship.")
            .font(.largeTitle)
            .fontWeight(.regular)
            .padding(50)
            .glassBackgroundEffect()
    }
    
    private var buttonAttachment: some View {
        
        let inactiveRed = Color(red: 1, green: 0, blue: 0)
        let activeRed = Color(red: 0.8, green: 0.1, blue: 0.1)
        
        return Image(systemName: "button.programmable")
                .resizable()
                .scaledToFit()
                .foregroundStyle(isButtonHeld ? activeRed : inactiveRed)
                .frame(width: 200, height: 200)
                .animation(
                    Animation.linear(duration: 0.1),
                    value: isButtonHeld
                )
    }
    
    var body: some View {
        RealityView { content, attachments in
            await generatePlanetTravelView(content: content, attachments: attachments)
        } attachments: {
            Attachment(id: "attachment") {
                attachment
            }
            
            Attachment(id: "buttonAttachment") {
                buttonAttachment
            }
        }
        .task {
            rotateEarthSubscriber = rotateEarthPublisher.sink { _ in
                Task {
                    await earth.rotate(radiansPerSecond: 0.01, axis: .y)
                }
            }
        }
        .task {
            rotateMoonSubscriber = rotateMoonPublisher.sink { _ in
                Task {
                    await moon.rotate(radiansPerSecond: 0.0005, axis: .y)
                }
            }
        }
        .gesture(
            LongPressGesture(minimumDuration: 0.1, maximumDistance: 0.5)
                .targetedToEntity(buttonAttachmentEntity)
                .updating($isButtonHeld, body: { value, gestureState, transaction in
                    gestureState = value.gestureValue
                })
        )
    }
}

// MARK: - RealityContentView and RealityViewAttachments Setup

extension SpaceshipView {
    func generatePlanetTravelView(content: RealityViewContent, attachments: RealityViewAttachments) async {
        guard let scene = try? await Entity(named: "PlanetTravel", in: realityKitContentBundle) else { return }
        
        // Load in sun
        guard let sun = scene.findEntity(named: "Sun") else { return }
        self.sun = sun
        sun.generateCollisionShapes(recursive: true)
        
        // Load in earth
        guard let earth = scene.findEntity(named: "Earth") else { return }
        self.earth = earth
        earth.generateCollisionShapes(recursive: true)
        rotateEarthPublisher.send()
        
        // Load in moon
        guard let moon = scene.findEntity(named: "Moon") else { return }
        self.moon = moon
        moon.generateCollisionShapes(recursive: true)
        rotateMoonPublisher.send()
        
        // Load in and configure spaceship entity
        guard let spaceship = scene.findEntity(named: "Spaceship") else { return }
        self.spaceship = spaceship
        spaceship.transform.rotation = simd_quatf(angle: Float.pi, axis: [0, 1, 0])
        spaceship.components.set(InputTargetComponent(allowedInputTypes: .all))
        spaceship.generateCollisionShapes(recursive: true)
        headAnchor.addChild(spaceship)
        
        // Load in Skybox
        guard let skybox = ModelEntity.generateSkyBox(when: .onSpaceship) else { return }
        
        // Load in attachments
        guard let attachment = attachments.entity(for: "attachment") else { return }
        headAnchorAttachment.addChild(attachment)
        
        // Load in buttonAttachment
        guard let buttonAttachment = attachments.entity(for: "buttonAttachment") else { return }
        buttonAttachment.components.set(InputTargetComponent())
        buttonAttachment.generateCollisionShapes(recursive: true)
        buttonAttachmentEntity = buttonAttachment
        headAnchorAttachment.addChild(buttonAttachment)
        buttonAttachmentEntity.position.y = -0.15
        
        content.add(skybox)
        content.add(sun)
        content.add(earth)
        content.add(moon)
        content.add(headAnchor)
        content.add(headAnchorAttachment)
    }
}
