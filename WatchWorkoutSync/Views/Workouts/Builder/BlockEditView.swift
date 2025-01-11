//
//  BlockEditView.swift
//  Landmarks
//
//  Created by Calvin Korver on 1/4/25.
//  Copyright © 2025 Apple. All rights reserved.
//
import SwiftUI


struct BlockEditView: View {
    @StateObject private var viewModel: BlockEditViewModel

    
    init(blockState: Binding<BlockEditState>) {
        _viewModel = StateObject(wrappedValue: BlockEditViewModel(blockState: blockState.wrappedValue))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Block Name", text: $viewModel.blockName)
                .font(.headline)
                .padding(.bottom)
            
            Picker("Metric Type", selection: $viewModel.selectedMetric) {
                ForEach(BlockEditViewModel.MetricType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            .onChange(of: viewModel.selectedMetric) { _, newValue in
                viewModel.clearOtherMetric(newValue)
            }
            
            Group {
                if viewModel.selectedMetric == .distance {
                    HStack {
                        TextField("Distance", text: $viewModel.distanceString)
                            .keyboardType(.decimalPad)
                        Picker("", selection: $viewModel.selectedDistanceUnit) {
                            ForEach(DistanceUnit.allCases, id: \.self) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    .onChange(of: viewModel.distanceString) { viewModel.updateDistance() }
                    .onChange(of: viewModel.selectedDistanceUnit) { viewModel.updateDistance() }
                } else {
                    TextField("Duration (minutes:seconds)", text: $viewModel.durationString)
                        .keyboardType(.numberPad)
                        .onChange(of: viewModel.durationString) { viewModel.updateDuration() }
                }
            }
            .frame(height: 30)
            
            Toggle("Add Pace Constraint", isOn: $viewModel.showPaceConstraint)
            
            if viewModel.showPaceConstraint {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Pace Range (min:sec per mile)")
                        .font(.caption)
                    
                    MinutesSecondsRangePicker(
                        lowTotalSeconds: $viewModel.lowTotalSeconds,
                        highTotalSeconds: $viewModel.highTotalSeconds
                    )
                    .frame(height: 150)
                    .onChange(of: viewModel.lowTotalSeconds) { _ in
                        viewModel.updatePaceConstraint()
                    }
                    .onChange(of: viewModel.highTotalSeconds) { _ in
                        viewModel.updatePaceConstraint()
                    }
                }
            }


        }
        .padding(.vertical, 4)
    }
}

#Preview {
    CreateNewWorkoutView()
        .environment(ModelData())
}
