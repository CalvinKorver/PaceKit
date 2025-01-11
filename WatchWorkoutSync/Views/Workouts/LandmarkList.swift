/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view showing a list of landmarks.
*/

import SwiftUI

struct LandmarkList: View {
    @Environment(ModelData.self) var modelData
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(modelData.landmarks) { landmark in
                    NavigationLink(destination: WorkoutDetail(landmark: landmark)) {
                                                HStack {
                                                    Text(landmark.name)
                                                        .font(.system(size: 17))
                                                    Spacer()
                                                }
                                                .padding()
                        Spacer()
                        Text("Detail").foregroundStyle(Color.secondary)
                        
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
    LandmarkList()
        .environment(ModelData())
}
