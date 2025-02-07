//
//  WorkRestSection.swift
//  WatchWorkoutSync
//
//  Created by Calvin Korver on 2/4/25.
//

import SwiftUI

struct WorkRestSection: View {
    @ObservedObject var viewModel: CreateNewWorkoutViewModel
    
    var body: some View {
        SectionCard {
            VStack() {
                // Work Block Section - Always show either block or add button
                let workBlockStateIndex = viewModel.blocks.firstIndex(where: { type(of: $0.block) == WorkBlock.self })
                
                if let workBlockStateIndex = workBlockStateIndex {
                    let workBlockState = viewModel.blocks[workBlockStateIndex]
                    BlockEditListView(
                        viewModel: viewModel,
                        block: workBlockState,
                        index: workBlockStateIndex
                    )
                    
                    // Rest Section Logic:
                    // - If work block exists but has no rest, show enabled button
                    // - If work block has rest, show rest block editor
                    // - If no work block, show disabled button
                    if let workBlock = workBlockState.block as? WorkBlock {
                        if let rest = workBlock.rest {
                            // Show rest block editor when rest exists
                            SimpleBlockEditView(
                                viewModel: BlockEditViewModel(
                                    blockState: BlockEditState(
                                        block: rest,
                                        type: CooldownBlock.self
                                    )
                                )
                            )
                        } else {
                            // Show enabled Add Rest button when work block exists but no rest
                            Button(action: {
                                viewModel.addRestToWorkBlock()
                            }) {
                                BlockButton(title: "Add Rest", color: Color(.systemGray5))
                            }
                        }
                    }
                } else {
                    VStack(spacing: 12) {
                        Button(action: { viewModel.addEmptyBlock(blockType: WorkBlock.self) }) {
                            BlockButton(title: "Add Work", color: .green)
                        }
                    
                    
                        // Show disabled rest button when no work block exists
                        Button(action: {
                            viewModel.addRestToWorkBlock()
                        }) {
                            BlockButton(title: "Add Rest", color: Color(.systemGray5))
                        }
                        .disabled(true)
                    }
                }
            }
        }
    }
}

#Preview {
    @State var modelData = ModelData()
    
    VStack(spacing: 20) {
        // Empty state
        WorkRestSection(viewModel: {
            let vm = CreateNewWorkoutViewModel(modelData: modelData)
            return vm
        }())
        .previewDisplayName("Empty State")
        
        // With work block, no rest
        WorkRestSection(viewModel: {
            let vm = CreateNewWorkoutViewModel(modelData: modelData)
            let workBlock = WorkBlock(
                id: 1,
                distance: Distance(value: 1.25, unit: .miles),
                duration: nil
            )
            vm.blocks.append(BlockEditState(
                block: workBlock,
                type: WorkBlock.self
            ))
            return vm
        }())
//        .previewDisplayName("With Work Block")
        
//        // With work block and rest
//        WorkRestSection(viewModel: {
//            let vm = CreateNewWorkoutViewModel(modelData: modelData)
//            var workBlock = WorkBlock(
//                id: 1,
//                name: "Work Block",
//                distance: Distance(value: 1.25, unit: .miles),
//                duration: nil,
//                type: .mainSet
//            )
//            workBlock.rest = Block(
//                id: 2,
//                name: "Rest",
//                distance: Distance(value: 0.25, unit: .miles),
//                duration: nil,
//                type: .cooldown
//            )
//            vm.blocks.append(BlockEditState(
//                block: workBlock,
//                type: .mainSet
//            ))
//            return vm
//        }())
//        .previewDisplayName("With Work and Rest")
    }
    .padding()
}
