//
//  Texture-Resource.swift
//  SpacePatrol
//
//  Created by Saverio Negro on 19/05/25.
//

import SwiftUI
import RealityKit

extension TextureResource {
    
    static func getObjectTexture(named image: String) -> SimpleMaterial? {
        guard let textureResource = try? TextureResource.load(named: image) else { return nil }
        let texture = MaterialParameters.Texture(textureResource)
        let color = SimpleMaterial.BaseColor(texture: texture)
        
        var material = SimpleMaterial()
        material.color = color
        return material
    }
    
    static func getTextureForSkyBox(from image: String) -> UnlitMaterial? {
        guard let textureResource = try? Self.load(named: image) else { return nil }
        let texture = MaterialParameters.Texture(textureResource)
        
        var material = UnlitMaterial()
        material.color = UnlitMaterial.BaseColor(texture: texture)
        
        return material
    }
}
