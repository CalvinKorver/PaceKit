////
////  DistancePicker.swift
////  WatchWorkoutSync
////
////  Created by Calvin Korver on 1/18/25.
////
//
//
//import SwiftUI
//struct DistancePicker: View {
//    @ObservedObject var viewModel: BlockEditViewModel
//    @State private var wholeNumber: Int = 0
//    @State private var fractionNumber: Int = 0
//    
//    init(viewModel: BlockEditViewModel) {
//        self.viewModel = viewModel
//        // Initialize the values from viewModel.distanceString
//        let distance = Double(viewModel.distanceString) ?? 0
//        _wholeNumber = State(initialValue: Int(floor(distance)))
//        _fractionNumber = State(initialValue: Int(round((distance - floor(distance)) * 100)))
//    }
//    
//    private func updateDistance(whole: Int, fraction: Int) {
//        let distance = Double(whole) + (Double(fraction) / 100.0)
//        viewModel.distanceString = String(format: "%.2f", distance)
//        viewModel.updateDistance()
//    }
//    
//    var body: some View {
//        BasePickerView(
//            primaryValue: .init(
//                get: { wholeNumber },
//                set: {
//                    wholeNumber = $0
//                    updateDistance(whole: $0, fraction: fractionNumber)
//                }
//            ),
//            secondaryValue: .init(
//                get: { fractionNumber },
//                set: {
//                    fractionNumber = $0
//                    updateDistance(whole: wholeNumber, fraction: $0)
//                }
//            ),
//            primaryRange: Array(0...20),        // 0-20 miles
//            secondaryRange: Array(0...99),      // 0-99 hundredths
//            label: viewModel.selectedDistanceUnit.rawValue,
//            primaryFormat: "%d",
//            secondaryFormat: "%02d",
//            separator: "."
//        )
//    }
//}
////
////#Preview {
////    struct PreviewWrapper: View {
////        @StateObject private var viewModel = BlockEditViewModel(
////            blockState: BlockEditState(
////                block: WorkBlock(id: 1),
////                workoutType: .simple
////            )
////        )
////        
////        var body: some View {
////            DistancePicker(viewModel: viewModel)
////        }
////    }
////    
////    return PreviewWrapper()
////}
