//
//  PlanetTravelView.swift
//  SpacePatrol
//
//  Created by Saverio Negro on 25/05/25.
//

import SwiftUI
import RealityKit
import RealityKitContent
import Combine
import AVKit

struct PlanetTravelView: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
    @State private var landingPublisher: PassthroughSubject<Void, Never> = PassthroughSubject()
    @State private var landingSubsciber: Cancellable? = nil
    
    @State private var marsPublisher: PassthroughSubject<Void, Never> = PassthroughSubject()
    @State private var marsSubscriber: Cancellable? = nil
    
    let headAnchor = {
        let anchorEntity = AnchorEntity(.head)
        anchorEntity.position = SIMD3<Float>(0, -1.2, -0.5)
        
        return anchorEntity
    }()
    
    @State private var headAnchorAttachment = {
        let anchorEntity = AnchorEntity(.head)
        anchorEntity.position = SIMD3<Float>(0.01, -0.26, -0.8)
        
        return anchorEntity
    }()
    
    
    @State private var skybox = ModelEntity()
    @State private var scene = Entity()
    @State private var sun = Entity()
    @State private var mars = Entity()
    @State private var spaceship = Entity()
    @State private var inputText = ""
    @GestureState private var isButtonHeld = false
    
    private var attachment: some View {
        VStack {
            Image(systemName: "button.programmable")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .foregroundStyle(isButtonHeld ? .brown : .red)
                .padding()
                .gesture(
                    LongPressGesture(minimumDuration: 2, maximumDistance: 0.2)
                        .updating($isButtonHeld, body: { value, gestureState, transaction in
                            gestureState = value
                        })
                        .onEnded { _ in
                            // Communicate to subscriber that landing action was performed
                            landingPublisher.send()
                        }
                )
            
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
    }
    
    var body: some View {
        RealityView { content, attachments in
            await setupContentEntity(content: content, attachments: attachments)
        } attachments: {
            Attachment(id: "attachment") {
                attachment
            }
        }
        .task {
            await initiateTravelSequence()
        }
    }
}

// MARK: - Utility Functions
extension PlanetTravelView {

    func awaitForLandingAction() async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            landingSubsciber = landingPublisher.sink { _ in
                continuation.resume()
            }
        }
    }

    func initiateTravelSequence() async {
        
        // Show and animate robot assistant message
        await Utility.animateText(text: "Let's speed our ride up to land on Mars sooner. Long press the red button to activate light speed.", inputText: $inputText)
        
        // Wait for the user to long press the red button
        await awaitForLandingAction()
        
        // Show robot assistant message to report about light-speed mode
        await Utility.animateText(text: "Light speed modality on!", inputText: $inputText)
        
        // Change skybox material to video material
        Bundle.main.videoMaterial(for: "lightspeed.mp4") { player, material in
            let radians = 90 * Float.pi / 180
            
            skybox.model?.mesh = .generateSphere(radius: 2000)
            skybox.model?.materials = [material]
            skybox.transform.rotation = simd_quatf(angle: radians, axis: SIMD3<Float>(0, 1, 0))
            player.play()
        }
        
        // Await for the video being played
        try! await Task.sleep(nanoseconds: Time.getNanosecondsFromSeconds(seconds: 8))
        
        // Show Mars in immersive space
        marsPublisher.send()
        mars.transform.translation.y = 25
        
        // Get sun a bit farther
        sun.transform.translation.z = -1000000
        
        // Reset skybox mesh and materials
        skybox.model?.mesh = .generateSphere(radius: 30000000)
        guard let material = TextureResource.getTextureForSkyBox(from: "Space") else { return }
        skybox.model?.materials = [material]
        
        // Show robot assistant message to communicate about the landing
        await Utility.animateText(text: "We are landing on Mars", inputText: $inputText)
        
        // Await for the landing to happen
        try! await Task.sleep(nanoseconds: Time.getNanosecondsFromSeconds(seconds: 10))
        
        // Load `PlanetView` into the `ImmersiveScene` scene object
        viewModel.appFlowState = .onPlanet
    }
}

// MARK: - Content Setup for `PlanetTravelView`

extension PlanetTravelView {
    func setupContentEntity(content: RealityViewContent, attachments: RealityViewAttachments) async {
        // Load in scene
        guard let scene = try? await Entity(named: "PlanetTravel", in: realityKitContentBundle) else { return }
        self.scene = scene
        
        // Load in initial skybox
        guard let skybox = ModelEntity.generateSkyBox(when: .onSpaceship) else { return }
        self.skybox = skybox
        
        // Load in sun
        guard let sun = scene.findEntity(named: "Sun") else { return }
        self.sun = sun
        sun.generateCollisionShapes(recursive: true)
        
        // Load in spaceship
        guard let spaceship = scene.findEntity(named: "Spaceship") else { return }
        self.spaceship = spaceship
        spaceship.transform.rotation = simd_quatf(angle: Float.pi, axis: [0, 1, 0])
        spaceship.generateCollisionShapes(recursive: true)
        headAnchor.addChild(spaceship)
        
        // Load in assistant message attachment
        guard let message = attachments.entity(for: "attachment") else { return }
        headAnchorAttachment.addChild(message)
        
        // Load in Mars
        guard let mars = scene.findEntity(named: "Mars") else { return }
        self.mars = mars
        marsSubscriber = marsPublisher.sink { _ in
            content.add(mars)
            
            Task {
                await self.mars.rotate(radiansPerSecond: 0.01, axis: .y, while: viewModel.appFlowState == .planetTravel)
            }
        }
        
        content.add(skybox)
        content.add(sun)
        content.add(headAnchor)
        content.add(headAnchorAttachment)
    }
}
