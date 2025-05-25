//
//  ViewModel.swift
//  SpacePatrol
//
//  Created by Saverio Negro on 04/05/25.
//

import SwiftUI

class ViewModel: ObservableObject {
    @Published var appFlowState: AppFlowState = .onSpaceship
    @Published var assistantState: AssistantState = .idle
}
