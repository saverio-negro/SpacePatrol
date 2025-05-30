//
//  VectorDensity.swift
//  FieldKit
//
//  Created by Saverio Negro on 08/05/25.
//

import Foundation

public enum VectorDensity {
    case low
    case medium
    case high
    
    var stepover: Float {
        switch self {
        case .low:
            return 2.0
        case .medium:
            return 1.5
        case .high:
            return 1.0
        }
    }
    
    public var densityName: String {
        switch self {
        case .low:
            "Low"
        case .medium:
            "Medium"
        case .high:
            "High"
        }
    }
}
