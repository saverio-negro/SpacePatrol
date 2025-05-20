//
//  Texture-Resource.swift
//  SpacePatrol
//
//  Created by Saverio Negro on 19/05/25.
//

import SwiftUI
import RealityKit

extension TextureResource {
    static func getTextureForSkyBox(from image: String) -> UnlitMaterial? {
        guard let textureResource = try? Self.load(named: "Space") else { return nil }
        let texture = MaterialParameters.Texture(textureResource)
        
        var material = UnlitMaterial()
        material.color = UnlitMaterial.BaseColor(texture: texture)
        
        return material
    }
}
