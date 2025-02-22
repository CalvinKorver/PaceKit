//
//  WorkRestSection.swift
//  WatchWorkoutSync
//
//  Created by Calvin Korver on 2/4/25.
//

import SwiftUI

struct WorkRestSection: View {
    @ObservedObject var viewModel: CreateNewWorkoutViewModel
    @State var showPaceEditor: Bool = false
    @State var isPaced: Bool = false
    @State private var paceSeconds: Int = 0
    
    private var handleTogglePaced: Binding<Bool> {
        Binding(
            get: { isPaced },
            set: { newValue in
                isPaced = newValue
                if isPaced == false {
                    paceSeconds = 0
                    showPaceEditor = false
                } else {
                    if newValue && paceSeconds == 0 {
                        showPaceEditor = true
                    }
                }
            }
        )
    }
    
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
                    
                    
                    HStack {
                        Toggle("Paced", isOn: handleTogglePaced)
                            .frame(width: 190, alignment: .leading)
                        Spacer()
                        if paceSeconds != 0 {
                            PaceDisplay(paceSeconds: paceSeconds)
                                .onTapGesture {
                                    showPaceEditor = true
                                }
                        }
                    }
                    .padding(.bottom, 8)
                    
                    // Rest Section Logic:
                    // - If work block exists but has no rest, show enabled button
                    // - If work block has rest, show rest block editor
                    // - If no work block, show disabled button
                    if let workBlock = workBlockState.block as? WorkBlock {
                        if let rest = workBlock.restBlock {
                            // Show rest block editor when rest exists
                            BlockEditBase(
                                viewModel: BlockEditViewModel(
                                    blockState: BlockEditState(
                                        block: rest,
                                        type: SimpleBlock.self
                                    )
                                )
                            ).padding(.top)
                            
                        } else {
                            RestButton(viewModel: viewModel, isDisabled: false)
                        }
                    }
                } else {
                    VStack(spacing: 12) {
                        Button(action: { viewModel.addEmptyBlock(blockType: .work) }) {
                            BlockButton(title: "Add Work", color: .green)
                        }
                    
                        // Show disabled rest button when no work block exists
                        RestButton(viewModel: viewModel, isDisabled: true)
                    }
                }
                IntervalCountSection(
                    viewModel: viewModel
                )
            }

            
        }
        .sheet(isPresented: $showPaceEditor) {
            PacePickerSheet(viewModel: viewModel, paceSeconds: $paceSeconds)
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
    }
    .padding()
}


struct IntervalCountSection: View {
    @ObservedObject var viewModel: CreateNewWorkoutViewModel
    
    var body: some View {
        if let block = viewModel.blocks.first(where: { $0.block.blockType == .work }) {
            if let workBlock = block.block as? WorkBlock {
                HStack {
                    Text("Repeat: ")
                    Text(String(workBlock.repeats ?? 1))
                        .fontWeight(.semibold)
                    
                    Spacer()
                    Stepper(
                        value: Binding(
                            get: { workBlock.repeats ?? 1 },
                            set: { newValue in viewModel.updateRepeatedCount(newValue)}
                        ),
                        in: 1...10,
                        step: 1
                    ){}
                            
                }
            }
        }
    }
}


struct RestButton: View {
    @ObservedObject var viewModel: CreateNewWorkoutViewModel
    let isDisabled: Bool;
    
    var body: some View {
        Button(action: {
            viewModel.addRestToWorkBlock()
        }) {
            BlockButton(title: "Add Rest", color: Color(.systemGray5))
        }
        .disabled(isDisabled)
    }
}


// Component for displaying current pace
struct PaceDisplay: View {
    let paceSeconds: Int
    
    var formattedPace: String {
        let minutes = paceSeconds / 60
        let seconds = paceSeconds % 60
        return String(format: "%d:%02d m/mile", minutes, seconds)
    }
    
    var body: some View {
        Text(formattedPace)
            .foregroundColor(.secondary)
    }
}
