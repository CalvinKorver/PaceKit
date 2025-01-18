import SwiftUI

struct SimpleBlockEditView: View {
    @ObservedObject var viewModel: BlockEditViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Metric Type Selector
            Picker("Metric", selection: $viewModel.selectedMetric) {
                ForEach([BlockEditViewModel.MetricType.time, .distance], id: \.self) { metric in
                    Text(metric.rawValue).tag(metric)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: viewModel.selectedMetric) { newValue in
                viewModel.clearOtherMetric(newValue)
            }
            
            switch viewModel.selectedMetric {
            case .time:
                // Duration Input
                VStack(alignment: .center, spacing: 4) {
                    HStack {
                        
                        DurationPicker(
                            durationSeconds: $viewModel.durationSeconds,
                            onDurationChange: { newValue in
                                viewModel.updateDuration()
                            }
                            
                        )
                        
                    }
                    
//                    MinutesSecondsPicker(distance: Binding<Int>, durationSeconds: <#T##Binding<Int>#>, distanceUnit: <#T##String#>)
//
//                    TextField("Duration (MM:SS)", text: $viewModel.durationString)
//                        .keyboardType(.numberPad)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                        .onChange(of: viewModel.durationString) {
//                            viewModel.updateDuration()
//                        }
                }

                
            case .distance:
                // Distance Input
                VStack(alignment: .leading, spacing: 4) {
                        DistancePicker(viewModel: viewModel)
                }
                .onChange(of: viewModel.distanceString) {
                    viewModel.updateDistance()
                }
                
                if let distance = viewModel.blockState.block.distance {
                    Text("Total Distance: \(String(format: "%.2f", distance.value)) \(distance.unit.rawValue)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
            default:
                EmptyView()
            }
        }
    }
}

#Preview {
    let block = Block(
        id: 1,
        name: "Sample Block",
        distance: Distance(value: 5.0, unit: .kilometers),
        duration: Duration(seconds: 1800),
        paceConstraint: nil
    )
    
    return SimpleBlockEditView(
        viewModel: BlockEditViewModel(
            blockState: BlockEditState(
                block: block,
                workoutType: .simple
            )
        )
    )
    .padding()
}
