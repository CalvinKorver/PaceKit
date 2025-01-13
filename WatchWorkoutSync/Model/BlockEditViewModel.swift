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
    @Published var durationString = ""
    @Published var selectedDistanceUnit = DistanceUnit.miles
    @Published var paceTotalSeconds: Int = 300  // 5:00
    @Published var highTotalSeconds: Int = 360 // 6:00
    
    enum MetricType: String, CaseIterable {
        case distance = "Distance"
        case time = "Time"
        case pace = "Pace"
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
            durationString = formatSecondsToMinutesSeconds(Int(duration.seconds))
            selectedMetric = .time
            print("Initialized with duration: \(duration.seconds) seconds")
        }
        
        // Initialize pace constraint
        if let paceConstraint = blockState.block.paceConstraint {
            showPaceConstraint = true
            paceTotalSeconds = paceConstraint.pace
            highTotalSeconds = paceConstraint.paceHigh
            print("Initialized with pace constraint: \(paceConstraint.paceLow)-\(paceConstraint.paceHigh)")
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
            durationString = ""
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
    
    func updateDistance() {
        print("Updating distance: \(distanceString) \(selectedDistanceUnit)")
        var updatedBlock = blockState.block
        if let distanceValue = Double(distanceString) {
            updatedBlock.distance = Distance(
                value: distanceValue,
                unit: selectedDistanceUnit
            )
            print("Set distance to: \(distanceValue) \(selectedDistanceUnit)")
        } else {
            updatedBlock.distance = nil
            print("Cleared distance")
        }
        blockState.block = updatedBlock
        objectWillChange.send()
    }
    
    func updateDuration() {
        print("Updating duration: \(durationString)")
        var updatedBlock = blockState.block
        if let seconds = parseMinutesSeconds(durationString) {
            updatedBlock.duration = Duration(seconds: Double(seconds))
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
        if showPaceConstraint {
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
    
    // Helper functions for time formatting
    func formatSecondsToMMSS(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func formatSecondsToMinutesSeconds(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    private func parseMinutesSeconds(_ timeString: String) -> Int? {
        let components = timeString.split(separator: ":")
        if components.count == 2,
           let minutes = Int(components[0]),
           let seconds = Int(components[1]) {
            return minutes * 60 + seconds
        }
        return nil
    }
}
