//
//  VectorFieldControlsView.swift
//  SpacePatrol
//
//  Created by Saverio Negro on 29/05/25.
//

import SwiftUI
import FieldKit

struct VectorFieldControlsView: View {
    
    @Binding var fieldType: FieldType
    @Binding var fieldWidth: Float
    @Binding var fieldHeight: Float
    @Binding var fieldDepth: Float
    @Binding var fieldDensity: VectorDensity
    @Binding var isFieldActive: Bool
    @Binding var duration: TimeInterval
    @Binding var magnitude: Float
    
    // Radial field controls
    @Binding var radialDirection: RadialDirection
    
    // Spiral field controls
    @Binding var aboutAxis: RotationAxis
    @Binding var rotation: RotationDirection
    
    @FocusState var isFocused: Bool
    
    var action: () -> Void
    
    let fieldTypes: Array<FieldType> = [.radial, .spiral]
    let fieldDensities: Array<VectorDensity> = [.low, .medium, .high]
    let radialDirections: Array<RadialDirection> = [.inward, .outward]
    let axes: Array<RotationAxis> = [.x, .y, .z]
    let rotationDirections: Array<RotationDirection> = [.clockwise, .counterclockwise]
    let durations: [TimeInterval] = [5, 10, 15]
    let magnitudeValues: [Float] = [2, 5, 10]
    
    init(
        fieldType: Binding<FieldType>,
        fieldWidth: Binding<Float>,
        fieldHeight: Binding<Float>,
        fieldDepth: Binding<Float>,
        fieldDensity: Binding<VectorDensity>,
        isFieldActive: Binding<Bool>,
        radialDirection: Binding<RadialDirection>,
        aboutAxis: Binding<RotationAxis>,
        rotation: Binding<RotationDirection>,
        duration: Binding<TimeInterval>,
        magnitude: Binding<Float>,
        
        buttonAction: @escaping () -> Void
    ) {
        self._fieldType = fieldType
        self._fieldWidth = fieldWidth
        self._fieldHeight = fieldHeight
        self._fieldDepth = fieldDepth
        self._fieldDensity = fieldDensity
        self._isFieldActive = isFieldActive
        self._radialDirection = radialDirection
        self._aboutAxis = aboutAxis
        self._rotation = rotation
        self._duration = duration
        self._magnitude = magnitude
        self.action = buttonAction
    }
    
    var radialFieldControls: some View {
        VStack {
            
            Section {
                Text("Radial direction")
                    .font(.title)
                
                // Select vector field radial direction
                Picker("Radial Direction", selection: $radialDirection) {
                    ForEach(self.radialDirections, id: \.self) { radialDirection in
                        Text(radialDirection.radialDirectionName)
                            .font(.title)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Section {
                
                Text("Magnitude")
                    .font(.title)
                
                Picker("Magnitude", selection: $magnitude) {
                    ForEach(magnitudeValues, id: \.self) { value in
                        Text(String(value))
                            .font(.title)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding()
        }
    }
    
    var spiralFieldControls: some View {
        VStack {
            Section {
                Text("The axis the rotation is about")
                    .font(.title)
                
                Picker("Axis", selection: $aboutAxis) {
                    ForEach(axes, id: \.self) { axis in
                        Text(axis.axisName)
                            .font(.title)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding()
            
            Section {
                Text("Enter the wise of rotation")
                
                Picker("Rotation", selection: $rotation) {
                    ForEach(rotationDirections, id: \.self) { direction in
                        Text(direction.rotationDirectionName)
                            .font(.title)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding()
            
            Section {
                
                Text("Magnitude")
                    .font(.title)
                
                Picker("Magnitude", selection: $magnitude) {
                    ForEach(magnitudeValues, id: \.self) { value in
                        Text(String(value))
                            .font(.title)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding()
        }
    }
    
    var body: some View {
        VStack {
            Text("Vector Field Controls")
                .font(.extraLargeTitle2)
                .padding()
            
            // Select vector field type
            Section {
                Text("Vector Field Type")
                    .font(.title)
                Picker("Vector Field Type", selection: $fieldType) {
                    ForEach(fieldTypes, id: \.self) { fieldType in
                        Text(fieldType.typeName)
                            .font(.title)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding()
            
            
            // Select vector field volume information
            Section {
                Text("Vector Field Volume")
                    .font(.title)
                    .padding()
                
                Text("Width:")
                TextField("Width", value: $fieldWidth, format: .number).font(.title)
                
                Text("Height:")
                TextField("Height", value: $fieldHeight, format: .number).font(.title)
                
                Text("Depth:")
                TextField("Depth", value: $fieldDepth, format: .number).font(.title)
            }
            .padding()
            
            Section {
                // Select vector field density
                Text("Vector Field Density")
                    .font(.title)
                Picker("Vector Field Density", selection: $fieldDensity) {
                    ForEach(fieldDensities, id: \.self) { fieldDensity in
                        Text(fieldDensity.densityName)
                            .font(.title)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding()
            
            Section {
                // Select the vector field duration
                Text("Field Duration")
                    .font(.title)
                Picker("Duration", selection: $duration) {
                    ForEach(durations, id: \.self) { duration in
                        Text(String(duration))
                            .font(.title)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding()
            
            switch fieldType {
            case .radial:
                radialFieldControls
            case .spiral:
                spiralFieldControls
            }
            
            Toggle(isOn: $isFieldActive) {
                Text("Spawn Vector Field")
                    .font(.largeTitle)
            }
            .toggleStyle(.button)
            .padding()
        }
        .onChange(of: isFieldActive) { _, _ in
            self.action()
        }
        .padding(100)
        .frame(minWidth: 300, minHeight: 300)
        .glassBackgroundEffect()
    }
}
