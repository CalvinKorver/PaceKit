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
                
                if blockState.workoutType == .pacer {
                    // Pacer-specific UI
                    VStack(alignment: .leading, spacing: 16) {
                        // Distance Input
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Distance (required)")
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
                        
                        // Pace Selector
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Target Pace (min/mile)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            MinutesSecondsPicker(
                                distance: Binding(
                                    get: {
                                        if let dist = viewModel.blockState.block.distance?.value {
                                            return Int(dist)
                                        }
                                        return 1609 // Default to 1 mile
                                    },
                                    set: { _ in }  // Read-only for distance
                                ),
                                durationSeconds: Binding(
                                    get: { viewModel.pacerModeSeconds },
                                    set: { newValue in
                                        viewModel.pacerModeSeconds = newValue
                                        viewModel.updateDurationFromPace()
                                    }
                                ),
                                distanceUnit: viewModel.selectedDistanceUnit.rawValue
                            )
                        }
                        
                        // Show calculated duration
                        if let duration = viewModel.blockState.block.duration {
              
                            Text("Total Duration: \(formatSecondsToMMSS(Int(duration.seconds)))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                } else {
                    // Original UI for non-pacer workouts
                    // ... keep existing non-pacer UI ...
                }
            }
            .padding()
            .onChange(of: viewModel.blockState.block) { _, newBlock in
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
        paceConstraint: PaceConstraint(id: 1, pace: 300)
    )
    
    return BlockEditView(
        blockState: .constant(BlockEditState(
            block: block,
            workoutType: .pacer
        ))
    )
    .padding()
}
