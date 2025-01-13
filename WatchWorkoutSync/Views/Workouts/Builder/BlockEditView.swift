
// BlockEditView.swift
import SwiftUI

struct BlockEditView: View {
    @Binding var blockState: BlockEditState
    @StateObject private var viewModel: BlockEditViewModel
    
    init(blockState: Binding<BlockEditState>) {
        _blockState = blockState
        _viewModel = StateObject(wrappedValue: BlockEditViewModel(blockState: blockState.wrappedValue))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Block Name
            TextField("Block Name", text: $viewModel.blockName)
                .font(.headline)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            // Metric Type Selection
            VStack(alignment: .leading, spacing: 4) {
                Text("Measurement Type")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Picker("Metric Type", selection: $viewModel.selectedMetric) {
                    ForEach(BlockEditViewModel.MetricType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: viewModel.selectedMetric) { _, newValue in
                    viewModel.clearOtherMetric(newValue)
                }
            }
            
            // Distance or Duration Input
            Group {
                if viewModel.selectedMetric == .distance {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Distance")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            TextField("Value", text: $viewModel.distanceString)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Picker("Unit", selection: $viewModel.selectedDistanceUnit) {
                                ForEach(DistanceUnit.allCases, id: \.self) { unit in
                                    Text(unit.rawValue.capitalized).tag(unit)
                                }
                            }
                            .frame(width: 100)
                        }
                    }
                    .onChange(of: viewModel.distanceString) { viewModel.updateDistance() }
                    .onChange(of: viewModel.selectedDistanceUnit) { viewModel.updateDistance() }
                } else {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Duration (minutes:seconds)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        TextField("00:00", text: $viewModel.durationString)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: viewModel.durationString) { viewModel.updateDuration() }
                    }
                }
            }
            
            // Pace Constraint Section
            Toggle("Add Pace Constraint", isOn: $viewModel.showPaceConstraint)
                .onChange(of: viewModel.showPaceConstraint) { viewModel.updatePaceConstraint() }
            
            if viewModel.showPaceConstraint {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Pace Range (min:sec per mile)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    MinutesSecondsRangePicker(
                        lowTotalSeconds: $viewModel.paceTotalSeconds,
                        highTotalSeconds: $viewModel.highTotalSeconds
                    )
                    .frame(height: 150)
                    .onChange(of: viewModel.paceTotalSeconds) { viewModel.updatePaceConstraint() }
                    .onChange(of: viewModel.highTotalSeconds) { viewModel.updatePaceConstraint() }
                }
            }
        }
        .padding()
                .onChange(of: viewModel.blockState.block) { _, newBlock in
                    print("BlockEditView - Updating parent state with new block:")
                    print("Name: \(newBlock.name)")
                    print("Distance: \(String(describing: newBlock.distance))")
                    print("Duration: \(String(describing: newBlock.duration))")
                    
                    var updatedState = blockState
                    updatedState.block = newBlock
                    blockState = updatedState
                }
    }
}

struct BlockEditState: Identifiable {
    var id: Int { block.id }  // Use the block's id as the BlockEditState's id
    var block: Block
    var workoutType: WorkoutType
}

#Preview {
    let block = Block(
        id: 1,
        name: "Sample Block",
        distance: Distance(value: 5.0, unit: .kilometers),
        duration: Duration(seconds: 1800),
        paceConstraint: PaceConstraint(id: 1, pace: 300, paceHigh: 360)
    )
    
    return BlockEditView(
        blockState: .constant(BlockEditState(
            block: block,
            workoutType: .pacer
        ))
    )
    .padding()
}
