import SwiftUI

struct MinutesSecondsPicker: View {
    @Binding var distance: Int       // Distance in meters
    @Binding var durationSeconds: Int
    let distanceUnit: String        // "meters", "kilometers", or "miles"
    
    // Calculate pace in seconds per mile
    private var paceInSeconds: Int {
        get {
            let distanceInMiles = switch distanceUnit {
                case "miles": Double(distance)
                case "kilometers": Double(distance) * 0.621371
                default: Double(distance) * 0.000621371 // meters to miles
            }
            
            guard distanceInMiles > 0 else { return 0 }
            return Int(Double(durationSeconds) / distanceInMiles)
        }
        set {
            // When pace changes, update duration based on distance
            let distanceInMiles = switch distanceUnit {
                case "miles": Double(distance)
                case "kilometers": Double(distance) * 0.621371
                default: Double(distance) * 0.000621371 // meters to miles
            }
            
            durationSeconds = Int(distanceInMiles * Double(newValue))
        }
    }
    
    var body: some View {
        BasePacePickerView(
            selectedSeconds: Binding(
                get: {
                    let distanceInMiles = switch distanceUnit {
                        case "miles": Double(distance)
                        case "kilometers": Double(distance) * 0.621371
                        default: Double(distance) * 0.000621371 // meters to miles
                    }
                    
                    guard distanceInMiles > 0 else { return 360 } // Default to minimum pace if distance is 0
                    let calculatedPace = Int(Double(durationSeconds) / distanceInMiles)
                    // Clamp the pace to our valid range
                    return min(max(calculatedPace, 360), 780)
                },
                set: { newPaceSeconds in
                    let distanceInMiles = switch distanceUnit {
                        case "miles": Double(distance)
                        case "kilometers": Double(distance) * 0.621371
                        default: Double(distance) * 0.000621371 // meters to miles
                    }
                    
                    durationSeconds = Int(distanceInMiles * Double(newPaceSeconds))
                }
            ),
            secondsLow: 360,   // 6:00 min/mile
            secondsHigh: 780,  // 13:00 min/mile
            incrementSeconds: 5,
            label: " mins/mile"
        )
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var distance = 1609 // 1 mile in meters
        @State private var duration = 420  // 7 minutes
        
        var body: some View {
            MinutesSecondsPicker(
                distance: $distance,
                durationSeconds: $duration,
                distanceUnit: "meters"
            )
        }
    }
    
    return PreviewWrapper()
}
