//
//  FieldDensity.swift
//  SpacePatrol
//
//  Created by Saverio Negro on 29/05/25.
//

enum FieldDensity {
    case low
    case medium
    case high
    
    var densityName: String {
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
