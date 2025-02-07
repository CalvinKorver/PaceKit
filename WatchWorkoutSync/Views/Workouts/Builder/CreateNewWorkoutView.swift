import SwiftUI
// CreateNewWorkoutView.swift
struct CreateNewWorkoutView: View {
    @Environment(ModelData.self) var modelData
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: CreateNewWorkoutViewModel
    @FocusState private var workoutNameIsFocused: Bool
    
    init() {
        _viewModel = StateObject(wrappedValue: CreateNewWorkoutViewModel(modelData: ModelData()))
        workoutNameIsFocused = true
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                VStack {
                    // Workout Name Field
                    WorkoutNameField(
                        text: Binding(
                            get: { viewModel.workoutName },
                            set: { viewModel.updateWorkoutName($0) }
                        ),
                        isFocused: $workoutNameIsFocused
                    )
                    
                    // Blocks Header
                    BlocksHeader()
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // Warmup Block Section
                            BlockSection(
                                viewModel: viewModel,
                                blockType: WarmupBlock.self
                            )
                            
                            // Work/Rest Section
                            WorkRestSection(viewModel: viewModel)
                            
                            // Cooldown Block Section
                            BlockSection(
                                viewModel: viewModel,
                                blockType: CooldownBlock.self
                            )
                        }
                    }
                    .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.saveWorkout()
                        dismiss()
                    }
                    .disabled(!viewModel.isWorkoutValid)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Helper Views
struct WorkoutNameField: View {
    let text: Binding<String>
    let isFocused: FocusState<Bool>.Binding
    
    var body: some View {
        TextField("Workout Name", text: text)
            .frame(alignment: .leading)
            .focused(isFocused)
            .font(.largeTitle.bold())
            .padding(EdgeInsets(top: 16, leading: 18, bottom: 0, trailing: 20))
    }
}

struct BlocksHeader: View {
    var body: some View {
        HStack {
            Text("BLOCKS")
                .padding(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 0))
                .frame(alignment: .leading)
                .foregroundStyle(.secondary)
                .font(.subheadline)
                .padding(.top)
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct BlockSection: View {
    @ObservedObject var viewModel: CreateNewWorkoutViewModel
    let blockType: Block.Type
    
    var body: some View {
        SectionCard {
            if let block = viewModel.blocks.first(where: { type(of: $0.block.self) == blockType }),
               let index = viewModel.blocks.firstIndex(where: { type(of: $0.block.self) == blockType }) {
                BlockEditListView(
                    viewModel: viewModel,
                    block: block,
                    index: index
                )
            } else {
                AddBlockButton(
                    blockType: blockType,
                    action: { viewModel.addEmptyBlock(blockType: blockType) }
                )
            }
        }
    }
}

struct BlockEditListView: View {
    @ObservedObject var viewModel: CreateNewWorkoutViewModel
    let block: BlockEditState
    let index: Int
    
    var body: some View {
        List {
            Group {
                if type(of: block.block) == WorkBlock.self {
                    CustomBlockEditView(
                        viewModel: BlockEditViewModel(
                            blockState: viewModel.binding(for: block).wrappedValue
                        )
                    )
                } else {
                    SimpleBlockEditView(
                        viewModel: BlockEditViewModel(
                            blockState: viewModel.binding(for: block).wrappedValue
                        )
                    )
                }
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            .listSectionSeparator(.hidden)
            .swipeActions(edge: .trailing) {
                Button(role: .destructive) {
                    viewModel.deleteBlock(at: index)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .listStyle(PlainListStyle())
        .frame(minHeight: 124) // Set minimum height for List

    }
}

struct BlockButton: View {
    let title: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: "plus.circle")
            Text(title)
        }
        .foregroundStyle(Color.primary)
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.5))
        .cornerRadius(8)
    }
}

#Preview {
    CreateNewWorkoutView()
        .environment(ModelData())
}
