//
//  RadialFieldSystem.swift
//  FieldKit
//
//  Created by Saverio Negro on 10/05/25.
//

import Foundation

struct RadialFieldSystem {
    let inOutDirection: RadialDirection
    let magnitude: Float
    let vectorPosition: SIMD3<Float>
    var vectorField: SIMD3<Float> {
        guard vectorPosition.length() > 0 else { return SIMD3<Float>(0, 0, 0) }
        
        let direction = inOutDirection == .inward ? -vectorPosition.normalize() : vectorPosition.normalize()
        
        return abs(magnitude) * direction
    }
}
