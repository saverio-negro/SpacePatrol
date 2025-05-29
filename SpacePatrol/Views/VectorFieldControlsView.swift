//
//  VectorFieldControlsView.swift
//  SpacePatrol
//
//  Created by Saverio Negro on 29/05/25.
//

import SwiftUI

struct VectorFieldControlsView: View {
    
    @Binding var fieldType: FieldType
    @Binding var fieldWidth: Float
    @Binding var fieldHeight: Float
    @Binding var fieldDepth: Float
    @Binding var fieldDensity: FieldDensity
    @Binding var isFieldActive: Bool
    var action: () -> Void
    
    let fieldTypes: Array<FieldType> = [.radial, .spiral, .custom]
    let fieldDensities: Array<FieldDensity> = [.low, .medium, .high]
    
    init(
        fieldType: Binding<FieldType>,
        fieldWidth: Binding<Float>,
        fieldHeight: Binding<Float>,
        fieldDepth: Binding<Float>,
        fieldDensity: Binding<FieldDensity>,
        isFieldActive: Binding<Bool>,
        buttonAction: @escaping () -> Void
    ) {
        self._fieldType = fieldType
        self._fieldWidth = fieldWidth
        self._fieldHeight = fieldHeight
        self._fieldDepth = fieldDepth
        self._fieldDensity = fieldDensity
        self._isFieldActive = isFieldActive
        self.action = buttonAction
    }
    
    var body: some View {
        VStack {
            Text("Vector Field Controls")
                .font(.extraLargeTitle2)
            
            // Select vector field type
            Picker("Vector Field Type", selection: $fieldType) {
                ForEach(fieldTypes, id: \.self) { fieldType in
                    Text(fieldType.typeName)
                }
            }
            
            // Select vector field volume information
            TextField("Width", value: $fieldWidth, format: .number)
            TextField("Height", value: $fieldHeight, format: .number)
            TextField("Depth", value: $fieldDepth, format: .number)
            
            // Select vector field density
            Picker("Vector Field Density", selection: $fieldDensity) {
                ForEach(fieldDensities, id: \.self) { fieldDensity in
                    Text(fieldDensity.densityName)
                }
            }
            
            Toggle(isOn: $isFieldActive) {
                Text("Spawn Vector Field")
                    .font(.largeTitle)
            }
        }
        .onChange(of: isFieldActive) { _, _ in
            self.action()
        }
        .padding()
        .frame(minWidth: 500, maxWidth: .infinity,
               minHeight: 500, maxHeight: .infinity
        )
        .glassBackgroundEffect()
    }
}
