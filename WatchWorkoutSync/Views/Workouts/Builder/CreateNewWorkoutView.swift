import SwiftUI

struct CreateNewWorkoutView: View {
    @Environment(ModelData.self) var modelData
    @Environment(\.dismiss) var dismiss
    
    @State private var workoutName = ""
    @State private var blocks: [BlockEditState] = []
    @State private var selectedWorkoutType: WorkoutType = .simple
    @FocusState private var workoutNameIsFocused: Bool
    
    init() {
        workoutNameIsFocused = true
    }
    
    private var newWorkoutId: Int {
        (modelData.workouts.map { $0.id }.max() ?? 0) + 1
    }
    
    private var newBlockId: Int {
        (blocks.map { $0.block.id }.max() ?? 1000) + 1
    }
    
    private func blockText() -> String {
        if selectedWorkoutType == .simple || selectedWorkoutType == .pacer {
            return "Block"
        } else {
            return "Blocks"
        }
    }
    
    private func blockButton(_ text: String) -> some View {
        HStack {
                Image(systemName: "plus.circle.fill")
                Text(text)
        }
        .foregroundStyle(text == "Add Block" ? Color.blue : Color.green)

    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Workout Name", text: $workoutName)
                   .focused($workoutNameIsFocused)
                   .frame(alignment: .leading)
                   .textFieldStyle(PlainTextFieldStyle())
                   .listRowInsets(EdgeInsets())
                   .font(.largeTitle.bold())
                   .listRowBackground(Color(.systemGray6))
                   .padding(.vertical, -8)
                   
                Section() {
                    Picker("Workout Type", selection: $selectedWorkoutType) {
                        ForEach(WorkoutType.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized)
                                .tag(type)
                        }
                    }
                }
                
                Section(header: Text(blockText())) {
                    ForEach($blocks) { $blockState in
                        BlockEditView(blockState: $blockState)
                    }
                    .onDelete(perform: deleteBlocks)
                    
                    if shouldShowAddBlockButton {
                        if (selectedWorkoutType.rawValue == "custom" && blocks.allSatisfy({$0.type != BlockType.warmup})) {
                            Button(action: {addEmptyBlock(blockType: .warmup)}) {
                                blockButton("Add Warmup Block")
                            }
                        }
                        Button(action: {addEmptyBlock(blockType: .mainSet)}) {
                            blockButton("Add Block")
                        }
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
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
            return blocks.isEmpty
        case .pacer:
            return blocks.isEmpty
        case .custom:
            return true
        }
    }

    
    private var isWorkoutValid: Bool {
        guard !workoutName.isEmpty && !blocks.isEmpty else { return false }
        
        switch selectedWorkoutType {
        case .simple:
            return areBlocksValid
        case .custom:
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
            case .custom:
                return true
            }
        }
        return true
    }
    
    private func addEmptyBlock(blockType: BlockType) {
        let newBlock = Block(
            id: newBlockId,
            name: "",
            distance: nil,
            duration: nil,
            paceConstraint: nil,
            type: blockType
        )
        
        let blockState = BlockEditState(
            block: newBlock,
            type: newBlock.type,
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
        
        modelData.workouts.append(newWorkout)
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
            
        case .custom:
            return true
        }
    }
}

#Preview {
    CreateNewWorkoutView()
        .environment(ModelData())
}
