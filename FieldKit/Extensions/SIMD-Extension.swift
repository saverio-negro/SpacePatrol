//
//  SIMD-Extension.swift
//  FieldKit
//
//  Created by Saverio Negro on 08/05/25.
//

import Foundation
import RealityKit

extension SIMD3 {
    static func mapToSIMD4<T: Numeric>(_ vector: SIMD3<T>) -> SIMD4<T> {
        return SIMD4<T>(
            vector.x,
            vector.y,
            vector.z,
            1
        )
    }
    
    // Get the length of the vector
    func length() -> Float {
        let x: Float = self.x as! Float
        let y: Float = self.y as! Float
        let z: Float = self.z as! Float
        return sqrtf((x * x) + (y * y) + (z * z))
    }
    
    // Get the normalized vector
    func normalize() -> SIMD3<Float> {
        let vector = self as! SIMD3<Float>
        let length = self.length()
        return self.length() > 0 ? vector / length : SIMD3<Float>(0, 0, 0)
    }
    
    // Define operator overload for SIMD3 vectors: Redefine how `/` and `*` work
    // when used with `SIMD3`.
    static func / (vector: SIMD3<Float>, scalar: Float) -> SIMD3<Float> {
        return SIMD3<Float>(
            vector.x / scalar,
            vector.y / scalar,
            vector.z / scalar
        )
    }
    
    static func * (vector: SIMD3<Float>, scalar: Float) -> SIMD3<Float> {
        return SIMD3<Float>(
            vector.x * scalar,
            vector.y * scalar,
            vector.z * scalar
        )
    }
    
    // Define unary operator `-` for the `SIMD3` type.
    static prefix func - (vector: SIMD3<Float>) -> SIMD3<Float> {
        return SIMD3<Float>(
            -1 * vector.x,
             -1 * vector.y,
             -1 * vector.z
        )
    }
}

extension SIMD4 {
    static func mapToSIMD3<T: Numeric>(_ vector: SIMD4<T>) -> SIMD3<T> {
        return SIMD3<T>(
            vector.x,
            vector.y,
            vector.z
        )
    }
}
