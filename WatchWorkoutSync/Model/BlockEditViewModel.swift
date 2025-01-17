import SwiftUI

class BlockEditViewModel: ObservableObject {
    @Published var blockState: BlockEditState {
        didSet {
            objectWillChange.send()
            print("BlockState updated in ViewModel")
        }
    }
    @Published var selectedMetric: MetricType = .time
    @Published var showPaceConstraint = false
    @Published var distanceString = ""
    @Published var durationSeconds: Int = 0
    @Published var selectedDistanceUnit = DistanceUnit.miles
    @Published var paceTotalSeconds: Int = 300  // 5:00
    @Published var pacerModeSeconds: Int = 480 // 8:00 min/mile default
    
    enum MetricType: String, CaseIterable {
        case distance = "Distance"
        case time = "Time"
        case pace = "Pace"
        case custom = "Custom"
    }
    
    init(blockState: BlockEditState) {
        self.blockState = blockState
        initializeFields()
    }
    
    func initializeFields() {
        // Initialize from Distance type
        if let distance = blockState.block.distance {
            distanceString = String(distance.value)
            selectedDistanceUnit = distance.unit
            selectedMetric = .distance
            print("Initialized with distance: \(distance.value) \(distance.unit)")
        }
        
        // Initialize from Duration type
        if let duration = blockState.block.duration {
            durationSeconds = duration.seconds
            selectedMetric = .time
            print("Initialized with duration: \(duration.seconds) seconds")
        }
        
        // Initialize pace constraint
        if blockState.workoutType != .simple, let paceConstraint = blockState.block.paceConstraint {
            showPaceConstraint = true
            paceTotalSeconds = paceConstraint.pace
            print("Initialized with pace constraint: \(paceConstraint.pace)")
        }
        
        if blockState.workoutType == .simple {
            var updatedBlock = blockState.block
            updatedBlock.name = "Main Block"
            self.blockState.block = updatedBlock
        }
    }
    
    var blockName: String {
        get {
            blockState.block.name
        }
        set {
            print("BlockEditViewModel - Setting block name to: \(newValue)")
            var updatedBlock = blockState.block
            updatedBlock.name = newValue
            blockState.block = updatedBlock
            objectWillChange.send()
        }
    }
    
    func clearOtherMetric(_ newType: MetricType) {
        print("Clearing metric for type: \(newType)")
        var updatedBlock = blockState.block
        if newType == .distance {
            updatedBlock.duration = nil
            durationSeconds = 0
            print("Cleared duration")
        } else if newType == .pace {
            updatedBlock.duration = nil
            updatedBlock.distance = nil
            print("Cleared duration and distance")
        } else {
            updatedBlock.distance = nil
            distanceString = ""
            print("Cleared distance")
        }
        blockState.block = updatedBlock
        objectWillChange.send()
    }
    
    // Modify updateDistance to handle pace calculations for pacer mode
    func updateDistance() {
        print("Updating distance: \(distanceString) \(selectedDistanceUnit)")
        var updatedBlock = blockState.block
        if let distanceValue = Double(distanceString) {
            updatedBlock.distance = Distance(
                value: distanceValue,
                unit: selectedDistanceUnit
            )
            
            // If in pacer mode, update duration based on pace
            if blockState.workoutType == .pacer {
                // Convert distance to miles for pace calculation
                let distanceInMiles = switch selectedDistanceUnit {
                    case .miles: distanceValue
                    case .kilometers: distanceValue * 0.621371
                    case .meters: distanceValue * 0.000621371
                }
                
                // Calculate total duration based on pace
                let totalSeconds = Int(distanceInMiles * Double(pacerModeSeconds))
                updatedBlock.duration = Duration(seconds: totalSeconds)
                durationSeconds = totalSeconds
            }
            
            print("Set distance to: \(distanceValue) \(selectedDistanceUnit)")
        } else {
            updatedBlock.distance = nil
            print("Cleared distance")
        }
        blockState.block = updatedBlock
        objectWillChange.send()
    }
    
    // Add method to update duration from pace
    func updateDurationFromPace() {
        guard let distance = blockState.block.distance else { return }
        
        // Convert distance to miles
        let distanceInMiles = switch distance.unit {
            case .miles: distance.value
            case .kilometers: distance.value * 0.621371
            case .meters: distance.value * 0.000621371
        }
        
        // Calculate new duration
        let totalSeconds = Int(distanceInMiles * Double(pacerModeSeconds))
        var updatedBlock = blockState.block
        updatedBlock.duration = Duration(seconds: totalSeconds)
        durationSeconds = totalSeconds
        blockState.block = updatedBlock
        objectWillChange.send()
    }

    
    func updateDuration() {
        print("Updating duration: \(durationSeconds)")
        var updatedBlock = blockState.block
        if let seconds = (durationSeconds != 0) ? Double(durationSeconds) : nil {
            updatedBlock.duration = Duration(seconds: Int(seconds))
            print("Set duration to: \(seconds) seconds")
        } else {
            updatedBlock.duration = nil
            print("Cleared duration")
        }
        blockState.block = updatedBlock
        objectWillChange.send()
    }
    
    func updatePaceConstraint() {
        print("Updating pace constraint - show: \(showPaceConstraint)")
        var updatedBlock = blockState.block
        
        // Only set pace constraint if not a simple workout
        if showPaceConstraint && blockState.workoutType != .simple {
            updatedBlock.paceConstraint = PaceConstraint(
                id: blockState.block.id,
                pace: paceTotalSeconds
            )
            print("Set pace constraint: \(paceTotalSeconds)")
        } else {
            updatedBlock.paceConstraint = nil
            print("Cleared pace constraint")
        }
        blockState.block = updatedBlock
        objectWillChange.send()
    }

}
