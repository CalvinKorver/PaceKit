import SwiftUI
import SwiftUI

struct BlockView: View {
    let block: Block
    let workout: Workout
    
    var body: some View {
        VStack() {
            // Block Type Indicator
            HStack {
                Text(block.blockType.name)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            
            // Main Metrics Display
            MetricsDisplay(block: block)
            
            // Work Block Specific Content
            if block.blockType == .work, let workBlock = block as? WorkBlock {
                WorkBlockDetails(workBlock: workBlock, workout: workout)
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// Separated Metrics Display Component
struct MetricsDisplay: View {
    let block: Block
    
    private var textColor: Color {
        block.blockType == .cooldown ? .blue : .black
    }
    
    var body: some View {
        HStack {
            HStack(alignment: .firstTextBaseline) {
                if block.metricType == .distance {
                    DistanceMetricView(
                        distance: block.distance,
                        textColor: textColor
                    )
                } else {
                    TimeMetricView(
                        duration: block.duration,
                        textColor: textColor
                    )
                }
            }
            Spacer()
        }
    }
}

// Distance Metric Component
struct DistanceMetricView: View {
    let distance: Distance?
    let textColor: Color
    
    var body: some View {
        Group {
            Text(formattedDistance)
                .font(.system(size: 58, weight: .bold))
                .foregroundStyle(textColor)
                .frame(alignment: .leading)
                
            
            Text(distance?.getUnitShorthand() ?? "")
                .font(.system(size: 26, weight: .light))
                .foregroundColor(.secondary)
        }
    }
    
    private var formattedDistance: String {
        guard let distance = distance else { return "0.00" }
        return String(format: "%.2f", distance.value)
    }
}

// Time Metric Component
struct TimeMetricView: View {
    let duration: Duration?
    let textColor: Color
    
    var body: some View {
        Group {
            Text(formattedTime)
                .font(.system(size: 58, weight: .bold))
                .foregroundStyle(textColor)
                .frame(maxWidth: 152)
            
            Text("mins")
                .font(.system(size: 26, weight: .light))
                .foregroundColor(.secondary)
        }
    }
    
    private var formattedTime: String {
        guard let duration = duration else { return "0:00" }
        let minutes = duration.seconds / 60
        let remainingSeconds = duration.seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

// Work Block Details Component
struct WorkBlockDetails: View {
    let workBlock: WorkBlock
    let workout: Workout
    
    var body: some View {
        VStack(spacing: 12) {
            // Show pace if applicable
            if let paceConstraint = workBlock.paceConstraint {
                HStack {
                    Text("Pace: \(formatPace(seconds: paceConstraint.duration))")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }
            
            // Show rest block if applicable
            if let rest = workBlock.restBlock {
                RestBlockSummary(rest: rest)
            }
            
            // Show repeats if applicable
            if let repeats = workBlock.repeats, repeats > 1 {
                HStack {
                    Text("Repeats: ")
                        .foregroundStyle(.secondary)
                    Text(String(repeats)).fontWeight(.semibold)
                    Spacer()
                }
            }
        }
    }
    
    private func formatPace(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d min/mile", minutes, remainingSeconds)
    }
}

// Rest Block Summary Component
struct RestBlockSummary: View {
    let rest: Block
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Rest:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            
            HStack {
                if rest.metricType == .distance, let distance = rest.distance {
                    Text("\(String(format: "%.2f", distance.value)) \(distance.getUnitShorthand())")
                        .foregroundStyle(.blue)
                } else if let duration = rest.duration {
                    let minutes = duration.seconds / 60
                    let seconds = duration.seconds % 60
                    Text("\(minutes):\(String(format: "%02d", seconds)) mins")
                        .foregroundStyle(.blue)
                }
                Spacer()
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(8)
    }
}

#Preview {
    VStack(spacing: 20) {
        // Preview a work block with rest
        BlockView(
            block: WorkBlock(
                id: 1,
                distance: Distance(value: 1.25, unit: .miles),
                duration: Duration(seconds: 600),
                paceConstraint: PaceConstraint(duration: 480, unit: .miles),
                rest: SimpleBlock(
                    id: 2,
                    blockType: .rest,
                    distance: Distance(value: 0.25, unit: .miles)
                ),
                repeats: 3
            ),
            workout: Workout(
                id: 1,
                name: "Test Workout",
                blocks: [],
                isFavorite: false,
                imageName: "runner"
            )
        )
        
        // Preview a cooldown block
        BlockView(
            block: SimpleBlock(
                id: 3,
                blockType: .cooldown,
                duration: Duration(seconds: 300)
            ),
            workout: Workout(
                id: 1,
                name: "Test Workout",
                blocks: [],
                isFavorite: false,
                imageName: "runner"
            )
        )
    }
    .padding()
    .background(Color(.systemGray6))
}
