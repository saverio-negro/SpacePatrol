//
//  ViewModel.swift
//  SpacePatrol
//
//  Created by Saverio Negro on 04/05/25.
//

import SwiftUI
import FieldKit

class ViewModel: ObservableObject {
    
    // App and robot assistant state properties
    @Published var appFlowState: AppFlowState = .onPlanet
    @Published var assistantState: AssistantState = .idle
    
    // Vector-Field-Control-Related Properties
    @Published var fieldType: FieldType = .radial
    @Published var fieldWidth: Float = 0
    @Published var fieldHeight: Float = 0
    @Published var fieldDepth: Float = 0
    @Published var fieldDensity: FieldDensity = .medium
    @Published var isFieldActive: Bool = false
}
