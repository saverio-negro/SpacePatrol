//
//  FieldAreaComponent.swift
//  FieldKit
//
//  Created by Saverio Negro on 08/05/25.
//

import Foundation
import RealityKit

// Class representing the area of the field
public class FieldAreaComponent {
    let width: Float?
    let height: Float?
    let depth: Float?
    
    public init(width: Float?, height: Float?, depth: Float?) {
        self.width = width
        self.height = height
        self.depth = depth
    }
}
