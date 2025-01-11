import SwiftUI


struct CreateNewWorkoutView: View {
    @Environment(ModelData.self) var modelData
    @Environment(\.dismiss) var dismiss
    
    @State private var workoutName = ""
    @State private var blocks: [BlockEditState] = []
    
    private var newWorkoutId: Int {
        (modelData.landmarks.map { $0.id }.max() ?? 0) + 1
    }
    
    private var newBlockId: Int {
        (blocks.map { $0.block.id }.max() ?? 1000) + 1
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Workout Details")) {
                    TextField("Workout Name", text: $workoutName)
                }
                
                Section(header: Text("Blocks")) {
                    ForEach($blocks) { $blockState in
                        BlockEditView(blockState: $blockState)
                    }
                    .onDelete(perform: deleteBlocks)
                    
                    Button(action: addEmptyBlock) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Block")
                        }
                    }
                }
            }
            .navigationTitle("New Workout")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveWorkout()
                    }
                    .disabled(workoutName.isEmpty || !blocks.allSatisfy { $0.isValid })
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    private func addEmptyBlock() {
        let newBlock = Block(
            id: newBlockId,
            name: "",
            distance: nil,
            durationSeconds: nil,
            distanceUnit: nil,
            paceConstraint: nil
        )
        blocks.append(BlockEditState(block: newBlock))
    }
    
    private func deleteBlocks(at offsets: IndexSet) {
        blocks.remove(atOffsets: offsets)
    }
    
    private func saveWorkout() {
        let newWorkout = Workout(
            id: newWorkoutId,
            name: workoutName,
            type: "simple",
            blocks: blocks.map { $0.block },
            isFavorite: false,
            imageName: "runner"
        )
        
        modelData.landmarks.append(newWorkout)
        dismiss()
    }
}

struct BlockEditState: Identifiable {
    var id: Int { block.id }
    var block: Block
    var isValid: Bool {
        guard !block.name.isEmpty else { return false }
        
        // Either distance with unit OR duration must be set
        let hasDistance = block.distance != nil && block.distanceUnit != nil
        let hasDuration = block.durationSeconds != nil && block.durationSeconds! > 0
        
        // If pace constraint exists, both high and low must be valid
        let hasPaceConstraint = block.paceConstraint != nil
        let validPaceConstraint = !hasPaceConstraint ||
            (block.paceConstraint!.paceLow > 0 && block.paceConstraint!.paceHigh >= block.paceConstraint!.paceLow)
        
        return (hasDistance || hasDuration) && validPaceConstraint
    }
}

#Preview {
    CreateNewWorkoutView()
        .environment(ModelData())
}
