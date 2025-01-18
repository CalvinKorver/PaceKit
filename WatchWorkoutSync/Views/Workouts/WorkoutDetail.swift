/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view showing the details for a landmark.
*/
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

    var body: some View {
        @Bindable var modelData = modelData
        ScrollView {
            VStack(spacing: 16) {
                // Header with name, favorite button, and sync button
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
                
                // Blocks
                if let blocks = workout.blocks {
                    ForEach(blocks, id: \.id) { block in
                        BlockView(block: block, workout: workout)
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
    WorkoutDetail(workout: ModelData().workouts[0])
        .environment(ModelData())
}


#Preview {
    let landmarks = ModelData().workouts
    WorkoutDetail(workout: landmarks[0])
        .environment(ModelData())
}
