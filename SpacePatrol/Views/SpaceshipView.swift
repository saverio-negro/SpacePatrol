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
    @State private var countdownPublisher: PassthroughSubject<Void, Never> = PassthroughSubject()
    @State private var countdownSubscriber: Cancellable?
    
    let headAnchor = {
        let anchorEntity = AnchorEntity(.head)
        anchorEntity.position = SIMD3<Float>(0, -1.2, -0.5)
        
        return anchorEntity
    }()
    
    let headAnchorAttachment = {
        let anchorEntity = AnchorEntity(.head)
        anchorEntity.position = SIMD3<Float>(0.01, -0.26, -0.8)
        
        return anchorEntity
    }()
    
    let headAnchorCountdown = {
        let anchorEntity = AnchorEntity(.head)
        let radians = 20 * (Float.pi / 180)
        anchorEntity.position = SIMD3<Float>(-0.03, 0.0, -0.4)
        anchorEntity.transform.rotation = simd_quatf(angle: radians, axis: [1, 0, 0])
        
        return anchorEntity
    }()
    
    @State private var spaceship = Entity()
    @State private var earth = Entity()
    @State private var moon = Entity()
    @State private var sun = Entity()
    @State private var count = ModelEntity()
    @State private var inputText = ""
    @State private var timeRemaining: TimeInterval = 15
    
    private var attachment: some View {
        RoundedRectangle(cornerRadius: 15)
            .foregroundStyle(.black.opacity(0.9))
            .overlay {
                VStack(alignment: .leading) {
                    Text("Robot Assistant:")
                        .font(.extraLargeTitle2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    
                    Text("\(inputText)")
                        .font(.extraLargeTitle2)
                        .fontWeight(.regular)
                        .padding()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 250)
    }
    
    var body: some View {
        RealityView { content, attachments in
            await generatePlanetTravelView(content: content, attachments: attachments)
        } update: { content, attachment in
            // Update content
            if timeRemaining >= 0 {
                
            }
        } attachments: {
            Attachment(id: "attachment") {
                attachment
            }
        }
        .task {
            rotateEarthSubscriber = rotateEarthPublisher.sink { _ in
                Task {
                    await earth.rotate(radiansPerSecond: 0.01, axis: .y, while: viewModel.appFlowState == .onSpaceship)
                }
            }
        }
        .task {
            rotateMoonSubscriber = rotateMoonPublisher.sink { _ in
                Task {
                    await moon.rotate(radiansPerSecond: 0.0005, axis: .y, while: viewModel.appFlowState == .onSpaceship)
                }
            }
        }
        .task {
            countdownSubscriber = countdownPublisher.sink { _ in
                Task {
                    
                    // Show and animate robot assistant message
                    await Utility.animateText(text: "Preparing for travelling to Mars. Please, buckle yourself up.", inputText: $inputText)
                    
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                        guard
                            timeRemaining > 0
                        else {
                            timer.invalidate()
                            viewModel.appFlowState = .planetTravel
                            return
                        }
                        timeRemaining -= 1
                        
                        count.model?.mesh = .generateText(
                            "\(timeRemaining.formatted(.number))",
                            extrusionDepth: 0.02,
                            font: .systemFont(ofSize: 0.1)
                        )
                    }
                }
            }
        }
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
        
        // Load in count
        count = ModelEntity(
            mesh: .generateText("\(timeRemaining.formatted(.number))", extrusionDepth: 0.02, font: UIFont.systemFont(ofSize: 0.1)),
            materials: [SimpleMaterial(color: .cyan, roughness: 0.2, isMetallic: false)]
        )
        headAnchorCountdown.addChild(count)
        
        // Trigger countdown
        countdownPublisher.send()
        
        content.add(skybox)
        content.add(sun)
        content.add(earth)
        content.add(moon)
        content.add(headAnchor)
        content.add(headAnchorAttachment)
        content.add(headAnchorCountdown)
    }
}
