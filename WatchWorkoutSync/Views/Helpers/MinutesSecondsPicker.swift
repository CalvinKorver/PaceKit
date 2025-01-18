import SwiftUI

struct MinutesSecondsPicker: View {
    @Binding var distance: Int       // Distance in meters
    @Binding var durationSeconds: Int
    let distanceUnit: String        // "meters", "kilometers", or "miles"
    
    @State private var minutes: Int
    @State private var seconds: Int
    
    init(distance: Binding<Int>, durationSeconds: Binding<Int>, distanceUnit: String) {
        self._distance = distance
        self._durationSeconds = durationSeconds
        self.distanceUnit = distanceUnit
        
        // Initialize the state variables
        let initialPaceSeconds = MinutesSecondsPicker.calculateInitialPaceSeconds(
            distance: distance.wrappedValue,
            duration: durationSeconds.wrappedValue,
            unit: distanceUnit
        )
        _minutes = State(initialValue: initialPaceSeconds / 60)
        _seconds = State(initialValue: initialPaceSeconds % 60)
    }
    
    // Helper function to calculate initial pace
    private static func calculateInitialPaceSeconds(distance: Int, duration: Int, unit: String) -> Int {
        let distanceInMiles = switch unit {
            case "miles": Double(distance)
            case "kilometers": Double(distance) * 0.621371
            default: Double(distance) * 0.000621371 // meters to miles
        }
        
        guard distanceInMiles > 0 else { return 360 } // Default to 6:00 min/mile
        let calculatedPace = Int(Double(duration) / distanceInMiles)
        return min(max(calculatedPace, 360), 780)  // Clamp between 6:00 and 13:00
    }
    
    // Helper function to convert distance to miles
    private func getDistanceInMiles() -> Double {
        switch distanceUnit {
            case "miles": Double(distance)
            case "kilometers": Double(distance) * 0.621371
            default: Double(distance) * 0.000621371 // meters to miles
        }
    }
    
    // Helper to calculate duration from pace
    private func updateDurationFromPace(minutes: Int, seconds: Int) {
        let paceSeconds = (minutes * 60) + seconds
        let distanceInMiles = getDistanceInMiles()
        guard distanceInMiles > 0 else { return }
        
        let clampedPace = min(max(paceSeconds, 360), 780)
        durationSeconds = Int(distanceInMiles * Double(clampedPace))
    }
    
    var body: some View {
        BasePickerView(
            primaryValue: .init(
                get: { minutes },
                set: {
                    minutes = $0
                    updateDurationFromPace(minutes: $0, seconds: seconds)
                }
            ),
            secondaryValue: .init(
                get: { seconds },
                set: {
                    seconds = $0
                    updateDurationFromPace(minutes: minutes, seconds: $0)
                }
            ),
            primaryRange: Array(6...13),     // 6-13 minutes
            secondaryRange: Array(0..<60),   // 0-59 seconds
            label: "min/mile",
            primaryFormat: "%d",
            secondaryFormat: "%02d",
            separator: ":"
        )
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var distance = 1609 // 1 mile in meters
        @State private var duration = 420  // 7 minutes
        
        var body: some View {
            VStack(spacing: 20) {
                MinutesSecondsPicker(
                    distance: $distance,
                    durationSeconds: $duration,
                    distanceUnit: "meters"
                )
                
                // Display current values for debugging
                Text("Distance: \(distance)m")
                Text("Duration: \(duration)s")
                Text("Pace: \(duration/60):\(String(format: "%02d", duration%60))/mile")
            }
            .padding()
        }
    }
    
    return PreviewWrapper()
}
