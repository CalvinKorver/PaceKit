import SwiftUI

struct DurationPicker: View {
    @Binding var durationSeconds: Int
    var onDurationChange: ((Int) -> Void)?
    
    // Constants for duration range
    private let minSeconds = 60   // 1 minute
    private let maxSeconds = 3600  // 1 hour
    
    @State private var minutes: Int
    @State private var seconds: Int
    
    // Convert total seconds to minutes and seconds
    
    init(durationSeconds: Binding<Int>, onDurationChange: ((Int) -> Void)? = nil) {
        self._durationSeconds = durationSeconds
        self.onDurationChange = onDurationChange
        
        // Initialize the state variables
        let initialDuration = durationSeconds.wrappedValue
        _minutes = State(initialValue: initialDuration / 60)
        _seconds = State(initialValue: initialDuration % 60)
    }
    
    
    private func updateDuration(_ newValue: Int) {
        let boundedValue = min(max(newValue, minSeconds), maxSeconds)
        durationSeconds = boundedValue
        onDurationChange?(boundedValue)
    }
    
    var body: some View {
        BasePickerView(
            primaryValue: .init(
                get: { minutes },
                set: { minutes = $0 }
            ),
            secondaryValue: .init(
                get: { seconds },
                set: { seconds = $0 }
            ),
            primaryRange: Array((minSeconds/60)...(maxSeconds/60)),  // 5-60 minutes
            secondaryRange: Array(0..<60),                           // 0-59 seconds
            label: "mins",
            primaryFormat: "%d",
            secondaryFormat: "%02d",
            separator: ":"
        )
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var duration = 1800  // 30 minutes
        
        var body: some View {
            VStack {
                DurationPicker(durationSeconds: $duration) { newDuration in
                    print("Duration changed to \(newDuration/60) minutes")
                }
                Text("Selected duration: \(duration/60) minutes")
            }
        }
    }
    
    return PreviewWrapper()
}
