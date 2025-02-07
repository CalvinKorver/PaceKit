import SwiftUI
class BlockEditViewModel: ObservableObject {
    @Published var blockState: BlockEditState {
        didSet {
            objectWillChange.send()
        }
    }
    @Published var selectedMetric: MetricType = .distance
    @Published var distance: Double = 0  // Store as double internally
    @Published var durationSeconds: Int = 0  // Store as seconds internally
    @Published var selectedDistanceUnit = DistanceUnit.miles
    @Published var repeatCount: Int = 1
    
    enum MetricType: String, CaseIterable {
        case distance = "Distance"
        case time = "Time"
    }
    
    init(blockState: BlockEditState) {
        self.blockState = blockState
        initializeFields()
    }
    
    func initializeFields() {
        // Initialize from Distance type
        if let blockDistance = blockState.block.distance {
            distance = blockDistance.value
            selectedDistanceUnit = blockDistance.unit
            selectedMetric = .distance
        }
        
        // Initialize from Duration type
        if let blockDuration = blockState.block.duration {
            durationSeconds = blockDuration.seconds
            selectedMetric = .time
        }
        
        // Initialize repeats if it's a WorkBlock
        if let workBlock = blockState.block as? WorkBlock {
            repeatCount = workBlock.repeats ?? 1
        }
    }
    
    func updateDistance() {
        let updatedBlock = blockState.block
        // Convert internal double to Distance type for the model
        updatedBlock.distance = Distance(
            value: distance,
            unit: selectedDistanceUnit
        )
        
        // If it's a WorkBlock, update duration based on pace
        if let workBlock = updatedBlock as? WorkBlock {
            let distanceInMiles = switch selectedDistanceUnit {
                case .miles: distance
                case .kilometers: distance * 0.621371
                case .meters: distance * 0.000621371
            }
            
            if let paceConstraint = workBlock.paceConstraint {
                let totalSeconds = Int(distanceInMiles * Double(paceConstraint.duration))
                workBlock.duration = Duration(seconds: totalSeconds)
                durationSeconds = totalSeconds
            }
        }
        
        blockState.block = updatedBlock
        objectWillChange.send()
    }
    
    func updateDuration() {
        let updatedBlock = blockState.block
        // Convert internal seconds to Duration type for the model
        updatedBlock.duration = durationSeconds > 0 ? Duration(seconds: durationSeconds) : nil
        blockState.block = updatedBlock
        objectWillChange.send()
    }
    
    func updateRepeats(_ newCount: Int) {
        if let workBlock = blockState.block as? WorkBlock {
            workBlock.repeats = newCount
            repeatCount = newCount
            objectWillChange.send()
        }
    }
    
    var isWorkBlock: Bool {
        return blockState.block is WorkBlock
    }
    
    var isWarmupBlock: Bool {
        return blockState.block is WarmupBlock
    }
    
    var isCooldownBlock: Bool {
        return blockState.block is CooldownBlock
    }

}
