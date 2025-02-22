import SwiftUI
class BlockEditViewModel: ObservableObject {
    @Published var blockState: BlockEditState {
        didSet {
            print("BlockState updated:")
             print("- Block ID: \(blockState.block.id)")
             print("- Distance: \(String(describing: blockState.block.distance))")
             print("- Duration: \(String(describing: blockState.block.duration))")
             print("- Metric Type: \(String(describing: blockState.block.metricType))")
            objectWillChange.send()
        }
    }
    @Published var selectedMetric: MetricType {
        didSet {
            // When metric changes, update the stored value in blockState
            var updatedState = blockState
            updatedState.selectedMetric = selectedMetric
            blockState = updatedState
        }
    }
    @Published var distance: Double = 0 {
        didSet {
            print("Distance changed to: \(distance)")
            updateDistance()
        }
    }
    
    @Published var durationSeconds: Int = 0 {
        didSet {
            print("Duration changed to: \(durationSeconds)")
            updateDuration()
        }
    }
    @Published var selectedDistanceUnit = DistanceUnit.miles
    @Published var repeatCount: Int = 1
    
    
    init(blockState: BlockEditState) {
        self.blockState = blockState
        self.selectedMetric = blockState.selectedMetric
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
        print("Updating distance: \(distance) \(selectedDistanceUnit)")
        let updatedBlock = blockState.block
        // Convert internal double to Distance type for the model
        updatedBlock.distance = Distance(
            value: distance,
            unit: selectedDistanceUnit
        )
        
        print("Updated block distance: \(String(describing: updatedBlock.distance))")
        
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
                print("Updated duration based on pace: \(totalSeconds)s")
            }
        }
        
        blockState.block = updatedBlock
        objectWillChange.send()
    }

    func clearOtherMetric(_ newType: MetricType) {
            print("Clearing metric for type: \(newType)")
            var updatedState = blockState
            var updatedBlock = blockState.block
            
            if newType == .distance {
                updatedBlock.duration = nil
                durationSeconds = 0
                print("Cleared duration")
            } else {
                updatedBlock.distance = nil
                distance = 0
                print("Cleared distance")
            }
            
            updatedState.block = updatedBlock
            updatedState.selectedMetric = newType // Update the stored metric type
            blockState = updatedState
            objectWillChange.send()
        }
    
    func updateDuration() {
        print("Updating duration: \(durationSeconds)s")
        let updatedBlock = blockState.block
        // Convert internal seconds to Duration type for the model
        updatedBlock.duration = durationSeconds > 0 ? Duration(seconds: durationSeconds) : nil
        print("Updated block duration: \(String(describing: updatedBlock.duration))")
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
        return blockState.block.blockType == .work
    }
    
    var isWarmupBlock: Bool {
        return blockState.block.blockType == .warmup
    }
    
    var isCooldownBlock: Bool {
        return blockState.block.blockType == .cooldown
    }

}
