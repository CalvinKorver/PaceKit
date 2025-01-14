import SwiftUI

struct CreateNewWorkoutView: View {
    @Environment(ModelData.self) var modelData
    @Environment(\.dismiss) var dismiss
    
    @State private var workoutName = ""
    @State private var blocks: [BlockEditState] = []
    @State private var selectedWorkoutType: WorkoutType = .simple
    
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
                    
                    Picker("Workout Type", selection: $selectedWorkoutType) {
                        ForEach(WorkoutType.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized)
                                .tag(type)
                        }
                    }
                }
                
                Section(header: Text("Blocks")) {
                    if blocks.isEmpty {
                        Text("Add a block to get started")
                            .foregroundColor(.secondary)
                            .italic()
                    }
                    
                    ForEach($blocks) { $blockState in
                        BlockEditView(blockState: $blockState)
                    }
                    .onDelete(perform: deleteBlocks)
                    
                    if shouldShowAddBlockButton {
                        Button(action: addEmptyBlock) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Block")
                            }
                        }
                    }
                }
                
                if !blocks.isEmpty {
                    Section {
                        if !areBlocksValid {
                            Text(validationMessage)
                                .foregroundColor(.red)
                                .font(.caption)
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
                    .disabled(!isWorkoutValid)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onChange(of: selectedWorkoutType) { oldValue, newValue in
                updateBlockStatesForWorkoutType(newValue)
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    private var shouldShowAddBlockButton: Bool {
        switch selectedWorkoutType {
        case .simple:
            return true
        case .pacer:
            return blocks.isEmpty
        }
    }
    
    private var validationMessage: String {
        switch selectedWorkoutType {
        case .simple:
            return "Please ensure all blocks have a name and either distance or duration set"
        case .pacer:
            return "Please ensure the block has a name, distance, and duration set"
        }
    }
    
    private var isWorkoutValid: Bool {
        guard !workoutName.isEmpty && !blocks.isEmpty else { return false }
        
        switch selectedWorkoutType {
        case .simple:
            return areBlocksValid
        case .pacer:
            return blocks.count == 1 && areBlocksValid
        }
    }
    
    private var areBlocksValid: Bool {
        for blockState in blocks {
            let nameValid = !blockState.block.name.isEmpty
            let hasDistance = blockState.block.distance != nil
            let hasDuration = blockState.block.duration != nil
            
            if !nameValid { return false }
            
            switch selectedWorkoutType {
            case .simple:
                if !hasDistance && !hasDuration { return false }
            case .pacer:
                if !hasDistance || !hasDuration { return false }
            }
        }
        return true
    }
    
    private func addEmptyBlock() {
        let newBlock = Block(
            id: newBlockId,
            name: "",
            distance: nil,
            duration: nil,
            paceConstraint: nil
        )
        
        let blockState = BlockEditState(
            block: newBlock,
            workoutType: selectedWorkoutType
        )
        blocks.append(blockState)
    }
    
    private func deleteBlocks(at offsets: IndexSet) {
        blocks.remove(atOffsets: offsets)
    }
    
    private func updateBlockStatesForWorkoutType(_ type: WorkoutType) {
        blocks = blocks.map { blockState in
            var updatedState = blockState
            updatedState.workoutType = type
            return updatedState
        }
        
        // For pacer workouts, ensure only one block
        if type == .pacer && blocks.count > 1 {
            blocks = Array(blocks.prefix(1))
        }
    }
    
    private func saveWorkout() {
        let newWorkout = Workout(
            id: newWorkoutId,
            name: workoutName,
            type: selectedWorkoutType.rawValue,
            blocks: blocks.map { $0.block },
            isFavorite: false,
            imageName: "runner"
        )
        
        modelData.landmarks.append(newWorkout)
        dismiss()
    }
}

// Extension to handle workout type validation rules
extension BlockEditState {
    var isValid: Bool {
        // Basic validation
        guard !block.name.isEmpty else { return false }
        
        // Validate based on workout type
        switch workoutType {
        case .simple:
            // Simple workouts need either distance or duration
            return block.distance != nil || block.duration != nil
            
        case .pacer:
            // Pacer workouts need both distance and duration
            return block.distance != nil && block.duration != nil
        }
    }
}

#Preview {
    CreateNewWorkoutView()
        .environment(ModelData())
}
