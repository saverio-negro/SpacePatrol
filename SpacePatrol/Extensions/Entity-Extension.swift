//
//  Entity-Extension.swift
//  SpacePatrol
//
//  Created by Saverio Negro on 04/05/25.
//

import SwiftUI
import RealityKit

enum Axis {
    case x
    case y
    case z
    
    var axisVector: SIMD3<Float> {
        switch self {
        case .x:
            [1, 0, 0]
        case .y:
            [0, 1, 0]
        case .z:
            [0, 0, 1]
        }
    }
}

extension Entity {
    func rotate(radiansPerSecond: Float, axis: Axis, while condition: Bool) async {
        
        var currentRadians: Float = 0
        
        let timeInterval: TimeInterval = 0.05
        let radiansPerTimeInterval = radiansPerSecond * Float(timeInterval)
        
        await Time.scheduledTimer(timeInterval: timeInterval, condition: condition) {
            currentRadians += radiansPerTimeInterval
            self.transform.rotation = simd_quatf(angle: currentRadians, axis: axis.axisVector)
        }
    }
}
