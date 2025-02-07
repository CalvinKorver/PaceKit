// CreateNewWorkoutViewModel.swift
import SwiftUI

class CreateNewWorkoutViewModel: ObservableObject {
    @Published var workoutName: String = ""
    @Published var blocks: [BlockEditState] = []
    @Published var selectedWorkoutType: WorkoutType = .custom
    
    private let modelData: ModelData
    
    init(modelData: ModelData) {
        self.modelData = modelData
    }
    
    var newWorkoutId: Int {
        (modelData.workouts.map { $0.id }.max() ?? 0) + 1
    }
    
    var newBlockId: Int {
        (blocks.map { $0.block.id }.max() ?? 1000) + 1
    }
    
    var hasWarmupBlock: Bool {
        blocks.contains(where: { $0.block is WarmupBlock })
    }
    
    var hasCooldownBlock: Bool {
        blocks.contains(where: { $0.block is CooldownBlock })
    }
    
    func addRestToWorkBlock() {
        // Find the work block
        if let workBlockIndex = blocks.firstIndex(where: { type(of: $0.block) == WorkBlock.self }),
           var workBlock = blocks[workBlockIndex].block as? WorkBlock {
            
            // Create new rest block
            let restBlock = CooldownBlock(
                id: newBlockId,
                distance: nil,
                duration: nil
            )
            
            // Attach rest block to work block
            workBlock.rest = restBlock
            
            // Update the block in the array
            var updatedState = blocks[workBlockIndex]
            updatedState.block = workBlock
            blocks[workBlockIndex] = updatedState
            
            objectWillChange.send()
        }
    }
    
    var isWorkoutValid: Bool {
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
            let hasDistance = blockState.block.distance != nil
            let hasDuration = blockState.block.duration != nil
            
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
    
    func updateWorkoutName(_ newName: String) {
        workoutName = newName
        objectWillChange.send()
    }
    
    func addEmptyBlock(blockType: Block.Type) {
        let newBlockId = (blocks.map { $0.block.id }.max() ?? 1000) + 1
        
        let blockState: BlockEditState
        if blockType == WorkBlock.self {
            let newBlock = WorkBlock(
                id: newBlockId,
                distance: nil,
                duration: nil,
                paceConstraint: nil,
                rest: nil,
                repeats: nil
            )
            blockState = BlockEditState(
                block: newBlock,
                type: WorkBlock.self
            )
        } else if blockType == CooldownBlock.self {
            let newBlock = CooldownBlock(
                id: newBlockId,
                distance: nil,
                duration: nil
            )
            blockState = BlockEditState(
                block: newBlock,
                type: CooldownBlock.self
            )
        } else {
            let newBlock = WarmupBlock(
                id: newBlockId,
                distance: nil,
                duration: nil
            )
            blockState = BlockEditState(
                block: newBlock,
                type: WarmupBlock.self
            )
        }
        
        blocks.append(blockState)
        objectWillChange.send()
    }
    
    func deleteBlock(at index: Int) {
        blocks.remove(at: index)
        objectWillChange.send()
    }
    
    func saveWorkout() {
        let newWorkout = Workout(
            id: newWorkoutId,
            name: workoutName,
            type: selectedWorkoutType.rawValue,
            blocks: blocks.map { $0.block },
            isFavorite: false,
            imageName: "runner"
        )
        
        modelData.workouts.append(newWorkout)
    }
    
    func binding(for blockState: BlockEditState) -> Binding<BlockEditState> {
        Binding(
            get: { blockState },
            set: { newValue in
                if let index = self.blocks.firstIndex(where: { $0.id == blockState.id }) {
                    self.blocks[index] = newValue
                    self.objectWillChange.send()
                }
            }
        )
    }
}
