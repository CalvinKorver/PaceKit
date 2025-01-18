/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view showing a list of landmarks.
*/

import SwiftUI

struct WorkoutList: View {
    @Environment(ModelData.self) var modelData
    
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
            }
            if totalTime > 0 {
                Text("Total:\(Int(totalTime)) min")
                    .fontWeight(.light)
            }
            Spacer()
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(modelData.workouts) { workout in
                    NavigationLink(destination: WorkoutDetail(workout: workout)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(workout.name)
                                    .font(.system(size: 17))
                                    .fontWeight(.medium)
                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 0))
                                workoutDetail(workout: workout)
                            }
                            Text("Detail").foregroundStyle(Color.secondary)
                            
                        }
                        .padding()
                    }
                    .listRowInsets(.init(top: 1, leading: 1, bottom: 1, trailing: 12))
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                    )
                }
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
                    }
                }
            }
            .background(Color(.systemGray6))
        }
    }
}

#Preview {
    WorkoutList()
        .environment(ModelData())
}
