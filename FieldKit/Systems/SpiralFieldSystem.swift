//
//  SpiralFieldSystem.swift
//  FieldKit
//
//  Created by Saverio Negro on 10/05/25.
//

import Foundation

struct SpiralFieldSystem {
    let aboutAxis: RotationAxis
    let rotation: RotationDirection
    let magnitude: Float
    let vectorPosition: SIMD3<Float>
    var vectorField: SIMD3<Float> {
        guard vectorPosition.length() > 0 else { return SIMD3<Float>(0, 0, 0) }
        
        let x = vectorPosition.x
        let y = vectorPosition.y
        let z = vectorPosition.z
        
        var direction = SIMD3<Float>.one
        
        switch aboutAxis {
        case .x:
            direction = rotation == .clockwise ? [0, z, -y] : [0, -z, y]
        case .y:
            direction = rotation == .clockwise ? [-z, 0, x]: [z, 0, -x]
        case .z:
            direction = rotation == .clockwise ? [y, -x, 0] : [-y, x, 0]
        }
        
        return magnitude * direction
    }
}
