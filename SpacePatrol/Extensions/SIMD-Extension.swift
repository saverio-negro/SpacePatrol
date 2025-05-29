//
//  SIMD-Extension.swift
//  SpacePatrol
//
//  Created by Saverio Negro on 5/29/25.
//

import Foundation

extension SIMD4 {
    var xyz: SIMD3<Scalar> {
        return self[SIMD3(0, 1, 2)]
    }
}

extension SIMD3<Float> {
    var xyzw: SIMD4<Float> {
        return SIMD4(self, 1)
    }
}
