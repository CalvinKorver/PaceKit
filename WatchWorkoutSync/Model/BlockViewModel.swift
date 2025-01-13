// BlockViewModel.swift
import SwiftUI
import WorkoutKit

struct BlockViewModel {
    private let block: Block
    private let workout: Workout
    
    init(block: Block, workout: Workout) {
        self.block = block
        self.workout = workout
    }
    
    var name: String {
        switch workout.type {
        case .simple:
            return "Main Block"
        case .pacer:
            return "Main Block"
        default:
            return block.name
        }
    }
    
    var isMainBlock: Bool {
        switch workout.type {
        case .simple:
            return true
        case .pacer:
            return true
        default:
            return false
        }
    }
    
    var distanceText: String? {
        guard let distance = block.distance else { return nil }
        
        let unitText = switch distance.unit {
        case .meters:
            "meters"
        case .kilometers:
            "km"
        case .miles:
            "miles"
        }
        
        return "\(distance.value) \(unitText)"
    }
    
    var durationText: String? {
        guard let duration = block.duration else { return nil }
        
        if duration.seconds >= 3600 {
            let hours = duration.seconds / 3600
            let minutes = (duration.seconds.truncatingRemainder(dividingBy: 3600)) / 60
            return "\(hours)h \(minutes)m"
        } else if duration.seconds >= 60 {
            let minutes = duration.seconds / 60
            let seconds = duration.seconds.truncatingRemainder(dividingBy: 60)
            return seconds > 0 ? "\(minutes)m \(seconds)s" : "\(minutes) minutes"
        } else {
            return "\(duration.seconds) seconds"
        }
    }
    
    var paceConstraintText: String? {
        guard let pace = block.paceConstraint else { return nil }
        return formatPace(low: pace.pace, high: pace.paceHigh)
    }
    
    private func formatPace(low: Int, high: Int) -> String {
        let lowFormatted = formatMinuteSeconds(seconds: low)
        let highFormatted = formatMinuteSeconds(seconds: high)
        return "\(lowFormatted) - \(highFormatted) min/mile"
    }
    
    private func formatMinuteSeconds(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    var backgroundColor: Color {
        switch workout.type {
        case .simple:
            return .white
        case .pacer:
            return Color(.systemBackground)
        default:
            return .white
        }
    }
    
    var borderColor: Color {
        if isMainBlock {
            return .green
        }
        return Color.gray.opacity(0.3)
    }
}
