//
//  FieldType.swift
//  SpacePatrol
//
//  Created by Saverio Negro on 29/05/25.
//

import SwiftUI

enum FieldType {
    case radial
    case spiral
    
    var typeName: String {
        switch self {
        case .radial:
            "Radial"
        case .spiral:
            "Spiral"
        }
    }
}
