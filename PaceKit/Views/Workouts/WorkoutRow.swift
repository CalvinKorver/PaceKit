/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A single row to be displayed in a list of landmarks.
*/

import SwiftUI

struct WorkoutRow: View {
    var landmark: Workout

    var body: some View {
        HStack {
            Image(systemName: "figure.run.circle")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 30)
            Text(landmark.name)

            Spacer()
            
            if (landmark.isFavorite) {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
            } else {
                FavoriteButton(isSet: .constant(false))
            }
        }
    }
}

#Preview {
    let landmarks = ModelData().workouts
    Group {
        WorkoutRow(landmark: landmarks[0])
        WorkoutRow(landmark: landmarks[1])
    }
}
