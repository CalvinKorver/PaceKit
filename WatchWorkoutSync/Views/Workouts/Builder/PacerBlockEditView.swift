import SwiftUI

struct PacerBlockEditView: View {
    @ObservedObject var viewModel: BlockEditViewModel
    
    var body: some View {
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
    }
}
