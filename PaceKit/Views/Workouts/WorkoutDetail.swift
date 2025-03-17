import SwiftUI
import HealthKit

struct WorkoutDetail: View {
    @Environment(ModelData.self) var modelData
    @Environment(\.colorScheme) var colorScheme
    var workout: Workout
    
    @State private var showingSyncAlert = false
    @State private var syncError: Error?
    @State private var isSyncing = false
    
    var landmarkIndex: Int {
        modelData.workouts.firstIndex(where: { $0.id == workout.id }) ?? 0
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
                        .foregroundColor(.primary)
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
        .background(Color(.systemBackground))
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
    let appState = AppState() // Create AppState instance
    
    WorkoutList()
        .environment(modelData)
        .environment(appState)
        
}
