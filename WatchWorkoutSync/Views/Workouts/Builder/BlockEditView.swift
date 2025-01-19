import SwiftUI

struct BlockEditView: View {
    @Binding var blockState: BlockEditState
    @StateObject private var viewModel: BlockEditViewModel
    
    init(blockState: Binding<BlockEditState>) {
        _blockState = blockState
        _viewModel = StateObject(wrappedValue: BlockEditViewModel(blockState: blockState.wrappedValue))
        
            
    }
    
    var body: some View {
            VStack(alignment: .leading, spacing: 12) {
            
                if blockState.workoutType == .pacer {
                    TextField("Block Name", text: $viewModel.blockName)
                        .font(.headline)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    PacerBlockEditView(viewModel: viewModel)
                } else if blockState.workoutType == .simple || blockState.block.type == .warmup {
                    SimpleBlockEditView(viewModel: viewModel)
                } else {
                    CustomBlockEditView(viewModel: viewModel)
                }
            }
            .padding()
            .onChange(of: viewModel.blockState.block) { _, newBlock in
                var updatedState = blockState
                updatedState.block = newBlock
                blockState = updatedState
            }
        }
    }


struct BlockEditState: Identifiable {
    var id: Int { block.id }  // Use the block's id as the BlockEditState's id
    var block: Block
    var type: BlockType
    var workoutType: WorkoutType
}

//#Preview {
//    let block = Block(
//        id: 1,
//        name: "Sample Block",
//        distance: Distance(value: 5.0, unit: .kilometers),
//        duration: Duration(seconds: 1800),
//        paceConstraint: PaceConstraint(id: 1, pace: 300)
//    )
//    
//    return BlockEditView(
//        blockState: .constant(BlockEditState(
//            block: block,
//            type: BlockType.fromString("pacer")!,
//            workoutType: .pacer
//        ))
//    )
//    .padding()
//}
