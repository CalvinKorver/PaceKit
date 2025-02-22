import SwiftUI

// Protocol for block edit views
protocol BlockEditViewProtocol {
    var viewModel: BlockEditViewModel { get }
    var quantity: Double { get set }
    var seconds: Int { get set }
    var selectedMetric: MetricType { get set }
}

// Main block edit view - replaces both SimpleBlockEditView and CustomBlockEditView
struct BlockEditBase: View, BlockEditViewProtocol {
    @ObservedObject var viewModel: BlockEditViewModel
    @State var quantity: Double
    @State var seconds: Int
    @State var selectedMetric: MetricType
    let content: (() -> AnyView)?
    
    init(viewModel: BlockEditViewModel, @ViewBuilder content: @escaping () -> some View = { EmptyView() }) {
        self.viewModel = viewModel
        
        // Initialize from the viewModel's actual values
        let initialDistance = viewModel.blockState.block.distance?.value ?? 0.0
        let initialDuration = viewModel.blockState.block.duration?.seconds ?? 300
        
        self._quantity = State(initialValue: initialDistance)
        self._seconds = State(initialValue: initialDuration)
        self._selectedMetric = State(initialValue: viewModel.blockState.selectedMetric)
        
        self.content = { AnyView(content()) }
    }
    
    var body: some View {
        TimeOrDistanceSelectorAndPicker(
            viewModel: viewModel,
            quantity: $quantity,
            seconds: $seconds,
            selectedMetric: $selectedMetric,
            content: content
        )
        .frame(minHeight: 120)
        .onAppear {
            // Ensure view model has the right values on appear
            if selectedMetric == .distance {
                viewModel.distance = quantity
            } else {
                viewModel.durationSeconds = seconds
            }
        }
    }
}

struct BlockEditState: Identifiable {
    var id: Int { block.id }
    var block: Block
    var type: Block.Type
    var selectedMetric: MetricType
    
    init(block: Block, type: Block.Type) {
        self.block = block
        self.type = Block.self
        // Initialize selectedMetric based on block properties
        self.selectedMetric = block.duration != nil ? .time : .distance
    }
}

// Custom view modifier for section cards
struct SectionCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(.horizontal, 16) // Fixed horizontal padding
            .padding(.vertical, 16)   // Fixed vertical padding
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct NestedSectionCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// Preview
#Preview {
    let block = Block(
        id: 1,
        blockType: .work,
        distance: Distance(value: 5.0, unit: .kilometers),
        duration: nil
    )

    Section {
        BlockEditBase(
            viewModel: BlockEditViewModel(
                blockState: BlockEditState(
                    block: block,
                    type: SimpleBlock.self
                )
            )
        )
        .padding()
        
    }
}


struct TimeOrDistanceSelectorAndPicker<Content: View>: View {
    @ObservedObject var viewModel: BlockEditViewModel
    @Binding var quantity: Double  // For distance in miles
    @Binding var seconds: Int      // For time in seconds
    @Binding var selectedMetric: MetricType
    let content: (() -> Content)?
    
    private var timeFormatted: String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    private var textColor: Color {
        viewModel.blockState.type == SimpleBlock.self ? .blue : .black
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Use the new MetricPickerView
            MetricPickerView(viewModel: viewModel, selectedMetric: $selectedMetric)
            
            // Rest of your existing implementation...
            HStack {
                // Quantity Display
                HStack(alignment: .firstTextBaseline) {
                    Group {
                        if selectedMetric == .distance {  // Use bound selectedMetric
                            Text(String(format: "%.2f", quantity))
                        } else {
                            Text(timeFormatted)
                        }
                    }
                    .font(.system(size: 58, weight: .bold))
                    .foregroundStyle(textColor)
                    .frame(maxWidth: 152)
                    
                    Text(selectedMetric == .time ? "mins" : "mi")  // Use bound selectedMetric
                        .font(.system(size: 26, weight: .light))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Dynamic Stepper based on selected metric
                Group {
                    if selectedMetric == .distance {
                        Stepper("",
                               value: $quantity,
                               in: 0...100,
                               step: 0.25)
                        .onChange(of: quantity) { _, newValue in
                            viewModel.distance = newValue
                            viewModel.selectedMetric = .distance
                        }
                    } else {
                        Stepper("",
                               value: $seconds,
                               in: 0...(60 * 60),
                               step: 10)
                        .onChange(of: seconds) { _, newValue in
                            viewModel.durationSeconds = newValue
                            viewModel.selectedMetric = .time
                        }
                    }
                }
                .labelsHidden()
            }
            .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
            
            if let content = content {
                content()
            }
        }
    }
}

struct MetricPickerView: View {
    @ObservedObject var viewModel: BlockEditViewModel
    @Binding var selectedMetric: MetricType  // Add binding for selectedMetric
    
    var body: some View {
        Picker("Metric", selection: $selectedMetric) {
            ForEach([MetricType.time, MetricType.distance] as [MetricType], id: \.self) { metric in
                Text(metric.rawValue).tag(metric)
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: selectedMetric) { _, newValue in
            viewModel.clearOtherMetric(newValue)
        }
    }
}

