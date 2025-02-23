import SwiftUI

// Sheet view for pace selection
struct PacePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var paceSeconds: Int
    @ObservedObject var viewModel: CreateNewWorkoutViewModel
    
    @State private var minutes: Int
    @State private var seconds: Int
    
    init(viewModel: CreateNewWorkoutViewModel, paceSeconds: Binding<Int>) {
        self.viewModel = viewModel
        self._paceSeconds = paceSeconds
        _minutes = State(initialValue: paceSeconds.wrappedValue / 60)
        _seconds = State(initialValue: paceSeconds.wrappedValue % 60)
    }
    
    private func savePaceConstraint() {
        let totalSeconds = minutes * 60 + seconds
        
        if let workBlockIndex = viewModel.blocks.firstIndex(where: { $0.block.blockType == .work }) {
            
            let paceConstraint = PaceConstraint(
                duration: totalSeconds,
                unit: .miles
            )
            
            var updatedBlock = viewModel.blocks[workBlockIndex].block as! WorkBlock
            updatedBlock.paceConstraint = paceConstraint
            
            viewModel.blocks[workBlockIndex].block = updatedBlock
        }
        paceSeconds = totalSeconds
        dismiss()
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Pace")
                    .font(.title)
                    .padding()
                
                BasePickerView(
                    primaryValue: .init(
                        get: { minutes },
                        set: { minutes = $0 }
                    ),
                    secondaryValue: .init(
                        get: { seconds },
                        set: { seconds = $0 }
                    ),
                    primaryRange: Array(6...13),     // 6-13 minutes
                    secondaryRange: Array(0..<60),   // 0-59 seconds
                    label: "min/mile",
                    primaryFormat: "%d",
                    secondaryFormat: "%02d",
                    separator: ":"
                )
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePaceConstraint()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
