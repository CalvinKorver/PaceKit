import SwiftUI

struct BlockView: View {
    let block: Block
    let workout: Workout
    
    private var timeFormatted: String {
        guard let duration = block.duration else { return "" }
        let minutes = duration.seconds / 60
        let remainingSeconds = duration.seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    private var distanceFormatted: String {
        guard let distance = block.distance else { return "" }
        return String(format: "%.2f", distance.value)
    }
    
    private var textColor: Color {
        block.blockType == .cooldown ? .blue : .black
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Block Type Indicator
            HStack {
                Text(block.blockType.name)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            
            // Main Metrics Display
            HStack {
                // Quantity Display
                HStack(alignment: .firstTextBaseline) {
                    Group {
                        if block.metricType == .distance {
                            Text(distanceFormatted)
                                .font(.system(size: 58, weight: .bold))
                                .foregroundStyle(textColor)
                                .frame(maxWidth: 152)
                            
                            Text(block.distance?.getUnitShorthand() ?? "")
                                .font(.system(size: 26, weight: .light))
                                .foregroundColor(.secondary)
                        } else {
                            Text(timeFormatted)
                                .font(.system(size: 58, weight: .bold))
                                .foregroundStyle(textColor)
                                .frame(maxWidth: 152)
                            
                            Text("mins")
                                .font(.system(size: 26, weight: .light))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
            }
            
            // Work Block Specific Content
            if block.blockType == .work {
                let workBlock = block as! WorkBlock
            
                // Show repeats if applicable
//                if let repeats = workBlock.repeats, repeats > 1 {
//                    HStack {
//                        Text("Repeats: \(repeats)")
//                            .foregroundStyle(.secondary)
//                        Spacer()
//                    }
//                }
                
                // Show pace if applicable
//                if let paceConstraint = workBlock.paceConstraint {
//                    HStack {
//                        Text("Pace: \(formatPace(seconds: paceConstraint.duration))")
//                            .foregroundStyle(.secondary)
//                        Spacer()
//                    }
//                }
                
                // Show rest block if applicable
                if let rest = workBlock.restBlock {
                    BlockView(block: rest, workout: workout)
                        .padding(.top, 8)
                }
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private func formatPace(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d min/mile", minutes, remainingSeconds)
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
