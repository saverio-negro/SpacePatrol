//
//  PlanetTravelView.swift
//  SpacePatrol
//
//  Created by Saverio Negro on 19/05/25.
//

import SwiftUI
import RealityKit
import RealityKitContent
import Combine

struct PlanetTravelView: View {
    
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
    @State private var spaceship = Entity()
    @State private var earth = Entity()
    @State private var moon = Entity()
    @State private var sun = Entity()
    var body: some View {
        RealityView { content in
            await generatePlanetTravelView(content: content)
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
    }
    
    func generatePlanetTravelView(content: RealityViewContent) async {
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
        
        guard let skybox = generateSkyBox() else { return }
        content.add(skybox)
        content.add(sun)
        content.add(earth)
        content.add(moon)
        content.add(headAnchor)
    }
    
    func generateSkyBox() -> ModelEntity? {
        let skybox = ModelEntity(
            mesh: .generateSphere(radius: 30000000)
        )
        
        guard let material = TextureResource.getTextureForSkyBox(from: "") else { return nil }
        skybox.model?.materials = [material]
        
        // Reverse sphere
        skybox.transform.scale = [-1.0, 1.0, 1.0]
        
        return skybox
    }
}
