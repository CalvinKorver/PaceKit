// BlockViewModel.swift
import SwiftUI
import WorkoutKit

struct BlockViewModel {
    let block: Block
    let workout: Workout
    
    init(block: Block, workout: Workout) {
        self.block = block
        self.workout = workout
    }
    

    var distanceText: String? {
        guard let distance = block.distance else { return nil }
        
        let _ = switch distance.unit {
        case .meters:
            "meters"
        case .kilometers:
            "km"
        case .miles:
            "miles"
        }
        
        return "\(distance.value) \(distance.getUnit())"
    }
    
    var durationText: String? {
        guard let duration = block.duration else { return nil }
        
        if duration.seconds >= 3600 {
            let hours = duration.seconds / 3600
            let minutes = (duration.seconds %  3600) / 60
            return "\(hours)h \(minutes)m"
        } else if duration.seconds >= 60 {
            let minutes = duration.seconds / 60
            let seconds = duration.seconds % 60
            return seconds > 0 ? "\(minutes)m \(seconds)s" : "\(minutes) minutes"
        } else {
            return "\(duration.seconds) seconds"
        }
    }
    
//    var paceConstraintText: String? {
//        guard let pace = block.paceConstraint else { return nil }
//        return formatPace(pace: pace.pace)
//    }
    
    func formatPace(pace: Int) -> String {
        let secondsFormatted = formatMinuteSeconds(seconds: pace)
        return "\(secondsFormatted)  min/mile"
    }
    
    private func formatMinuteSeconds(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    var backgroundColor: Color {
        
        return .white
        
    }
    
    var borderColor: Color {
//        if isMainBlock {
//            return .green
//        }
        return Color.gray.opacity(0.3)
    }
}
