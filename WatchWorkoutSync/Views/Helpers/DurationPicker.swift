//
//  DurationPicker.swift
//  WatchWorkoutSync
//
//  Created by Calvin Korver on 1/16/25.
//


import SwiftUI

struct DurationPicker: View {
    @Binding var durationSeconds: Int
    var onDurationChange: ((Int) -> Void)?

    
    // Constants for duration range
    private let minSeconds = 300          // 5 minute
    private let maxSeconds = 3600        // 1 hours
    private let incrementSeconds = 300    // 5 minutes
    
    var body: some View {
        BasePacePickerView(
            selectedSeconds: Binding(
                get: { 
                    // Round to nearest increment
                    let remainder = durationSeconds % incrementSeconds
                    let roundedSeconds = remainder >= incrementSeconds/2 
                        ? durationSeconds + (incrementSeconds - remainder)
                        : durationSeconds - remainder
                    
                    return min(max(roundedSeconds, minSeconds), maxSeconds)
                },
                set: { newValue in
                    durationSeconds = newValue
                    onDurationChange?(newValue)  // Call the callback when duration changes

                }
            ),
            secondsLow: minSeconds,
            secondsHigh: maxSeconds,
            incrementSeconds: incrementSeconds,
            label: "mins"
        )
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var duration = 1800  // 30 minutes
        
        var body: some View {
            VStack {
                DurationPicker(durationSeconds: $duration)
                Text("Selected duration: \(duration/60) minutes")
            }
        }
    }
    
    return PreviewWrapper()
}
