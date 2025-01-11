/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view showing the details for a landmark.
*/

import SwiftUI

struct WorkoutDetail: View {
    @Environment(ModelData.self) var modelData
    var landmark: Workout
    
    var landmarkIndex: Int {
        modelData.landmarks.firstIndex(where: { $0.id == landmark.id })!
    }

    var body: some View {
        @Bindable var modelData = modelData
        ScrollView {
            VStack(spacing: 16) {
                // Header with name and favorite button
                HStack {
                    Text(landmark.name)
                        .font(.largeTitle)
                        .bold()
                    Spacer()
                    FavoriteButton(isSet: $modelData.landmarks[landmarkIndex].isFavorite)
                }
                .padding(.horizontal)
                
                // Blocks
                ForEach(landmark.blocks, id: \.id) { block in
                    BlockView(block: block)
                }
            }
            .padding(.vertical)
            
        }
        .scrollContentBackground(.hidden)
        .background(Color(.systemGray6))
    }
}


#Preview {
    WorkoutDetail(landmark: ModelData().landmarks[0])
        .environment(ModelData())
}

#Preview {
    let landmarks = ModelData().landmarks
    WorkoutDetail(landmark: landmarks[0])
        .environment(ModelData())
}
