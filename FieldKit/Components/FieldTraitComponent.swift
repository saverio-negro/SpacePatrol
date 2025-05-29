//
//  FieldTraitComponent.swift
//  FieldKit
//
//  Created by Saverio Negro on 09/05/25.
//

import Foundation
import RealityKit

public enum RadialDirection {
    case inward
    case outward
    
    public var radialDirectionName: String {
        switch self {
        case .inward:
            "Inward"
        case .outward:
            "Outward"
        }
    }
}

public enum RotationAxis {
    case x
    case y
    case z
    
    public var axisName: String {
        switch self {
        case .x:
            "X"
        case .y:
            "Y"
        case .z:
            "Z"
        }
    }
}

public enum RotationDirection {
    case clockwise
    case counterclockwise
    
    public var rotationDirectionName: String {
        switch self {
        case .clockwise:
            "Clockwise"
        case .counterclockwise:
            "Counterclockwise"
        }
    }
}

public enum FieldTrait<Magnitude: Numeric> {
    
    public typealias VectorPosition = SIMD3<Float>
    public typealias VectorField = SIMD3<Float>
    public typealias MagnitudeFunctionType = (_ vectorPosition: VectorPosition, _ time: TimeInterval) -> Magnitude
    public typealias FieldFunctionType = (_ vectorPosition: VectorPosition, _ time: TimeInterval) -> VectorField
    
    case radial(direction: RadialDirection, magnitude: MagnitudeFunctionType)
    case spiral(aboutAxis: RotationAxis, rotation: RotationDirection, magnitude: MagnitudeFunctionType)
    case custom(fieldFunction: FieldFunctionType)
}

public class FieldTraitComponent {
    var fieldTrait: FieldTrait<Float>
    
    public init(fieldTrait: FieldTrait<Float>) {
        self.fieldTrait = fieldTrait
    }
}
