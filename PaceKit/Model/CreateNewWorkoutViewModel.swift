// CreateNewWorkoutViewModel.swift
import SwiftUI

class CreateNewWorkoutViewModel: ObservableObject {
    @Published var workoutName: String = ""
    @Published var blocks: [BlockEditState] = []
//    @Published var selectedWorkoutType: WorkoutType = .custom
    
    private var modelData: ModelData

    init(modelData: ModelData) {
        self.modelData = modelData
        print("ViewModel initialized with ModelData containing \(modelData.workouts.count) workouts")
    }
    
    var newWorkoutId: Int {
        (modelData.workouts.map { $0.id }.max() ?? 0) + 1
    }
    
    var newBlockId: Int {
        (blocks.map { $0.block.id }.max() ?? 1000) + 1
    }
    
    var hasWarmupBlock: Bool {
        blocks.contains(where: { $0.block.blockType == .warmup })
    }
    
    var hasCooldownBlock: Bool {
        blocks.contains(where: { $0.block.blockType == .cooldown })
    }
    
    func updateRepeatedCount(_ newCount: Int) {
        guard let workBlockIndex = blocks.firstIndex(where: { type(of: $0.block) == WorkBlock.self }),
              var workBlock = blocks[workBlockIndex].block as? WorkBlock else {
            return
        }
        
        
        workBlock.repeats = newCount
        
        var updatedState = blocks[workBlockIndex]
        updatedState.block = workBlock
        blocks[workBlockIndex] = updatedState
        
        objectWillChange.send()
    }
    
    
    func updateModelData(_ newModelData: ModelData) {
        print("Updating ModelData reference in ViewModel")
        print("Old workout count: \(modelData.workouts.count)")
        print("New workout count: \(newModelData.workouts.count)")
        self.modelData = newModelData
    }
    
    func addRestToWorkBlock() {
        guard let workBlockIndex = blocks.firstIndex(where: { type(of: $0.block) == WorkBlock.self }),
              var workBlock = blocks[workBlockIndex].block as? WorkBlock else {
            return
        }
        
        // Create new rest block
        let restBlock = SimpleBlock(
            id: newBlockId,
            blockType: .rest,
            distance: workBlock.metricType == .distance ? Distance(value: 0, unit: .miles) : nil,
            duration: workBlock.metricType == .time ? Duration(seconds: 0) : nil,
            metricType: workBlock.metricType ?? .distance
        )
        
        workBlock.restBlock = restBlock
        
        var updatedState = blocks[workBlockIndex]
        updatedState.block = workBlock
        blocks[workBlockIndex] = updatedState
        
        objectWillChange.send()
    }
    
    var isWorkoutValid: Bool {
        guard !workoutName.isEmpty && !blocks.isEmpty else { return false }
        
        return areBlocksValid
    }
    
    private var areBlocksValid: Bool {
        for blockState in blocks {
            let hasDistance = blockState.block.distance != nil
            let hasDuration = blockState.block.duration != nil
                return true
            
        }
        return true
    }
    
    func updateWorkoutName(_ newName: String) {
        workoutName = newName
        objectWillChange.send()
    }
    
    func addEmptyBlock(blockType: BlockType) {
        // Generate random ID
        let newBlockId = UUID().uuidString.hashValue
        
        let blockState: BlockEditState
        if blockType == .work {
            let newBlock = WorkBlock(
                id: newBlockId,
                distance: Distance(value: 1.0, unit: .miles),
                duration: nil,
                paceConstraint: nil,
                rest: nil,
                repeats: nil
            )
            blockState = BlockEditState(
                block: newBlock,
                type: WorkBlock.self
            )
        } else {
            let newBlock = SimpleBlock(
                id: newBlockId,
                blockType: blockType,
                distance: Distance(value: 1.0, unit: .miles),
                duration: nil
            )
            blockState = BlockEditState(
                block: newBlock,
                type: SimpleBlock.self
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
        // Debug print blocks before saving
        print("Saving workout with \(blocks.count) blocks:")
        for block in blocks {
            print("Block ID: \(block.id)")
            print("- Distance: \(String(describing: block.block.distance))")
            print("- Duration: \(String(describing: block.block.duration))")
            print("- Metric Type: \(String(describing: block.block.metricType))")
        }
        
        let newWorkout = Workout(
            id: newWorkoutId,
            name: workoutName,
            blocks: blocks.map { $0.block },
            isFavorite: false,
            imageName: "runner"
        )
        
        // Debug print the created workout
        print("Created new workout:")
        print("- ID: \(newWorkout.id)")
        print("- Name: \(newWorkout.name)")
        print("- Blocks count: \(String(describing: newWorkout.blocks?.count))")
        
        modelData.workouts.append(newWorkout)
        
        // Debug print modelData after saving
        print("Total workouts after save: \(modelData.workouts.count)")
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
