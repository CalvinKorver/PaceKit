import SwiftUI

// Protocol for block edit views
protocol BlockEditViewProtocol {
    var viewModel: BlockEditViewModel { get }
    var quantity: Double { get set }
}

// Base view that implements common functionality
struct BaseBlockEditView<Content: View>: View {
    @ObservedObject var viewModel: BlockEditViewModel
    @Binding var quantity: Double
    let content: () -> Content
    
    init(viewModel: BlockEditViewModel, quantity: Binding<Double>, @ViewBuilder content: @escaping () -> Content) {
        self.viewModel = viewModel
        self._quantity = quantity
        self.content = content
    }
    
    var body: some View {
        VStack {
            TimeOrDistanceSelectorAndPicker(viewModel: viewModel, quantity: $quantity) {
                content()
            }
        }
        .frame(minHeight: 120)
    
    }
}

// Simple Block Edit View Implementation
struct SimpleBlockEditView: View, BlockEditViewProtocol {
    @ObservedObject var viewModel: BlockEditViewModel
    @State var quantity: Double = 1.25
    
    var body: some View {
        BaseBlockEditView(viewModel: viewModel, quantity: $quantity) {
            // Any additional content specific to SimpleBlockEditView
            EmptyView()
        }
    }
}


// Custom Block Edit View Implementation
struct CustomBlockEditView: View, BlockEditViewProtocol {
    @ObservedObject var viewModel: BlockEditViewModel
    @State var quantity: Double = 1.25
    
    var body: some View {
            TimeOrDistanceSelectorAndPicker(viewModel: viewModel, quantity: $quantity) {
                // Custom content can go here
                EmptyView()
        }
        .frame(minHeight: 120) // Ensure minimum height

    }
}

struct BlockEditState: Identifiable {
    var id: Int { block.id }
    var block: Block
    var type: Block.Type
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
            .padding(.vertical, 12)   // Fixed vertical padding
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
//            .padding(.horizontal, 16) // Fixed horizontal padding
//            .padding(.vertical, 12)   // Fixed vertical padding
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
//            .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
    }
}

// Preview
#Preview {
    let block = Block(
        id: 1,
        distance: Distance(value: 5.0, unit: .kilometers),
        duration: nil
    )

    Section {
        SimpleBlockEditView(
            viewModel: BlockEditViewModel(
                blockState: BlockEditState(
                    block: block,
                    type: WarmupBlock.self
                )
            )
        )
        .padding()
        
        CustomBlockEditView(
            viewModel: BlockEditViewModel(
                blockState: BlockEditState(
                    block: block,
                    type: WorkBlock.self
                )
            )
        )
        .padding()
    }
}

struct TimeOrDistanceSelectorAndPicker<Content: View>: View {
    @ObservedObject var viewModel: BlockEditViewModel
    @Binding var quantity: Double
    let content: (() -> Content)?
    
    var body: some View {
        let textColor: Color = viewModel.blockState.type == CooldownBlock.self ? Color.blue : Color.black

        VStack(spacing: 24) {
            // Metric Type Selector
            Picker("Metric", selection: $viewModel.selectedMetric) {
                ForEach([BlockEditViewModel.MetricType.time, .distance], id: \.self) { metric in
                    Text(metric.rawValue).tag(metric)
                }
            }
            .pickerStyle(.segmented)
            
            let label = viewModel.selectedMetric == .time ? "mins" : "mi"
            
            // Quantity with Stepper
            HStack {
                // Quantity Display
                HStack(alignment: .firstTextBaseline) {
                    
                    let view = viewModel.selectedMetric == .distance ?
                    (Text(String(format: "%.2f", quantity))
                        .font(.system(size: 58, weight: .bold))
                        .foregroundStyle(textColor)
                        .frame(maxWidth: 152))
                    :
                    (Text(String(format: "%.2f", quantity))
                        .font(.system(size: 58, weight: .bold))
                        .foregroundStyle(textColor)
                        .frame(maxWidth: 152))
                    
                    view
                    
                    Text(label)
                        .font(.system(size: 26, weight: .light))
                        .foregroundColor(.secondary)
                    
                }
                Spacer()
                // Stepper
                Stepper("", value: $quantity, in: 0...100, step: 0.25)
                    .labelsHidden()
            }
            .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
            
            // Additional content specific to each implementation
            if let content = content {
                content()
            }

        }
    }
}
