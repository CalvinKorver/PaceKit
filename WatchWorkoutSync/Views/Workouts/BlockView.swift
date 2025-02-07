import SwiftUI
import WorkoutKit

struct BlockView: View {
    let viewModel: BlockViewModel
    
    init(block: Block, workout: Workout) {
        self.viewModel = BlockViewModel(block: block, workout: workout)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            
            if let distanceText = viewModel.distanceText {
                Text(distanceText)
                    .font(.subheadline)
            }
            
            if let durationText = viewModel.durationText {
                Text(durationText)
                    .font(.subheadline)
            }
            
//            if let paceText = viewModel.paceConstraintText {
//                Text(paceText)
//                    .font(.subheadline)
//            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.white))
                .stroke(viewModel.isMainBlock ? Color.green : Color.gray.opacity(0.3),
                       lineWidth: 2)
        )
        .padding(.horizontal)
    }
}
//
//#Preview {
//    // Create a sample workout and block for preview
//    let block = Block(id: 1,
//                      name: "Sample Block",
//                      duration: Duration(seconds: 600),
//                      type: .mainSet
//    )
//    let workout = Workout(
//        id: 1,
//        name: "Sample Workout",
//        type: "simple",
//        blocks: [block],
//        isFavorite: false,
//        imageName: "runner"
//    )
//    
//    BlockView(block: block, workout: workout)
//}
