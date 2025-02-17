import SwiftUI
import HealthKit

struct WorkoutDetail: View {
    @Environment(ModelData.self) var modelData
    var workout: Workout
    
    @State private var showingSyncAlert = false
    @State private var syncError: Error?
    @State private var isSyncing = false
    
    var landmarkIndex: Int {
        modelData.workouts.firstIndex(where: { $0.id == workout.id })!
    }
    
    // Helper method to organize blocks by type
    private func getBlocksByType() -> (warmup: Block?, work: Block?, cooldown: Block?) {
        var warmupBlock: Block?
        var workBlock: Block?
        var cooldownBlock: Block?
        
        if let blocks = workout.blocks {
            for block in blocks {
                switch block.blockType {
                case .warmup:
                    warmupBlock = block
                case .work:
                    workBlock = block
                case .cooldown:
                    cooldownBlock = block
                default:
                    break
                }
            }
        }
        
        return (warmupBlock, workBlock, cooldownBlock)
    }
    
    var body: some View {
        @Bindable var modelData = modelData
        
        ScrollView {
            VStack(spacing: 16) {
                // Header
                HStack {
                    Text(workout.name)
                        .font(.largeTitle)
                        .bold()
                    Spacer()
                    Button(action: {
                        Task {
                            await syncToWatch()
                        }
                    }) {
                        Image(systemName: "arrow.triangle.2.circlepath.circle")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.blue)
                    }
                    .disabled(isSyncing)
                    
                    FavoriteButton(isSet: $modelData.workouts[landmarkIndex].isFavorite)
                }
                .padding(.horizontal)
                
                if isSyncing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
                
                // Blocks Section Header
                HStack {
                    Text("Intervals")
                        .padding(EdgeInsets(top: 8, leading: 2, bottom: 0, trailing: 0))
                        .frame(alignment: .leading)
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                    Spacer()
                }
                .padding(.horizontal)
                
                // Organized Blocks Display
                let blocks = getBlocksByType()
                
                VStack(spacing: 14) {
                    // Warmup Block
                    if let warmup = blocks.warmup {
                        BlockView(block: warmup, workout: workout)
                            .padding(.horizontal)
                    }
                    
                    // Work Block (with potential rest)
                    if let work = blocks.work {
                        BlockView(block: work, workout: workout)
                            .padding(.horizontal)
                    }
                    
                    // Cooldown Block
                    if let cooldown = blocks.cooldown {
                        BlockView(block: cooldown, workout: workout)
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .scrollContentBackground(.hidden)
        .background(Color(.systemGray6))
        .alert("Sync Status", isPresented: $showingSyncAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            if let error = syncError {
                Text("Failed to sync: \(error.localizedDescription)")
            } else {
                Text("Workout successfully synced to Apple Watch!")
            }
        }
    }
}

// Extension to add HealthKit support to WorkoutDetail view
extension WorkoutDetail {
    func syncToWatch() async {
        let healthKitService = HealthKitService()
        
        do {
            try await healthKitService.requestAuthorization()
            try await healthKitService.saveWorkout(workout)
            
            await MainActor.run {
                syncError = nil
                showingSyncAlert = true
                isSyncing = false
            }
        } catch {
            await MainActor.run {
                syncError = error
                showingSyncAlert = true
                isSyncing = false
            }
            print("Error syncing workout to watch: \(error)")
        }
    }
}

#Preview {
    let modelData = ModelData()
    let workout = Workout(
        id: 1,
        name: "Test Workout",
        blocks: [
            SimpleBlock(
                id: 1,
                blockType: .warmup,
                distance: Distance(value: 1.0, unit: .miles)
            ),
            WorkBlock(
                id: 2,
                distance: Distance(value: 1.25, unit: .miles),
                duration: Duration(seconds: 600),
                paceConstraint: PaceConstraint(duration: 480, unit: .miles),
                rest: SimpleBlock(
                    id: 3,
                    blockType: .rest,
                    distance: Distance(value: 0.25, unit: .miles)
                ),
                repeats: 3
            ),
            SimpleBlock(
                id: 4,
                blockType: .cooldown,
                duration: Duration(seconds: 300)
            )
        ],
        isFavorite: false,
        imageName: "runner"
    )
    
    return WorkoutDetail(workout: workout)
        .environment(modelData)
}
