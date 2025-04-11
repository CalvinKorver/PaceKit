import SwiftUI

struct WorkoutList: View {
    @Environment(ModelData.self) var modelData
    @Environment(AppState.self) var appState
    @Environment(\.colorScheme) var colorScheme
    
    func workoutDetail(workout: Workout) -> some View {
        var totalDistance = 0.0
        var totalTime = 0
        var distanceUnit = ""
        if workout.blocks != nil, let blocks = workout.blocks {
                for block in blocks {
                if block.distance != nil, let distance = block.distance {
                    totalDistance += distance.getValue()
                    distanceUnit = block.distance!.getUnitShorthand()
                }
                
                if block.duration != nil, let duration = block.duration {
                    totalTime += duration.seconds
                }
            }
        }
        
        return HStack {
            if totalDistance > 0 {
                Text("Total: \(totalDistance, specifier: "%.1f") \(distanceUnit)")
                    .fontWeight(.light)
                    .foregroundColor(.primary)
            }
            if totalTime > 0 {
                Text("Total:\(Int(totalTime)) min")
                    .fontWeight(.light)
                    .foregroundColor(.primary)
            }
            Spacer()
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(modelData.workouts) { workout in
                    let _ = print("Rendering workout: \(workout.name) (ID: \(workout.id))")
                    NavigationLink(destination: WorkoutDetail(workout: workout)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(workout.name)
                                    .font(.system(size: 17))
                                    .fontWeight(.medium)
                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 0))
                                    .foregroundColor(.primary)
                                workoutDetail(workout: workout)
                            }
                            Text("Detail").foregroundStyle(Color.secondary)
                        }
                        .padding()
                    }
                    .listRowInsets(.init(top: 1, leading: 1, bottom: 1, trailing: 12))
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray5))
                    )
                }
            }
            .onAppear {
                print("\nWorkoutList appeared")
                print("Number of workouts: \(modelData.workouts.count)")
                for workout in modelData.workouts {
                    print("\nWorkout: \(workout.name) (ID: \(workout.id))")
                    if let blocks = workout.blocks {
                        print("Blocks: \(blocks.count)")
                        for block in blocks {
                            print("- Block ID: \(block.id)")
                            print("  Distance: \(String(describing: block.distance))")
                            print("  Duration: \(String(describing: block.duration))")
                        }
                    } else {
                        print("No blocks")
                    }
                }
            }
            .onChange(of: modelData.workouts) { oldValue, newValue in
                print("\nWorkouts changed")
                print("Old count: \(oldValue.count)")
                print("New count: \(newValue.count)")
            }
            .listRowSpacing(26)
            .padding()
            .listStyle(.plain)
            .navigationTitle("Workouts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    NavigationLink(destination: CreateNewWorkoutView()) {
                        Image(systemName: "plus.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.primary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.primary)
                    }
                    .padding()
                }
                
            }
            
            
            .background(Color(colorScheme == .dark ? .systemBackground : .systemGray6))
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
