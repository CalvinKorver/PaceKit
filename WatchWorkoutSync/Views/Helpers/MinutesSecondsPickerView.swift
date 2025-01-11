//
//  MinutesSecondsPickerView.swift
//  Landmarks
//
//  Created by Calvin Korver on 1/9/25.
//  Copyright © 2025 Apple. All rights reserved.
//
import SwiftUI

struct MinutesSecondsRangePicker: UIViewRepresentable {
    @Binding var lowTotalSeconds: Int
    @Binding var highTotalSeconds: Int
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UIPickerView {
        let picker = UIPickerView()
        picker.delegate = context.coordinator
        picker.dataSource = context.coordinator
        
        // Set initial selections
        picker.selectRow(lowTotalSeconds, inComponent: 0, animated: false)
        picker.selectRow(highTotalSeconds, inComponent: 1, animated: false)
        
        
        return picker
    }
    
    func updateUIView(_ uiView: UIPickerView, context: Context) {
        uiView.selectRow(lowTotalSeconds, inComponent: 0, animated: true)
        uiView.selectRow(highTotalSeconds, inComponent: 1, animated: true)
    }
    
    class Coordinator: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
        var parent: MinutesSecondsRangePicker
        
        init(_ pickerView: MinutesSecondsRangePicker) {
            self.parent = pickerView
        }
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 2 // Low and High components
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return 900 // 15 minutes worth of seconds (15 * 60)
        }
        
        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            let label = (view as? UILabel) ?? UILabel()
            
            let minutes = row / 60
            let seconds = row % 60
            label.text = String(format: "%02d:%02d", minutes, seconds)
            label.textAlignment = .center
            label.font = .monospacedSystemFont(ofSize: 20, weight: .medium)
            
            return label
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            if component == 0 {
                parent.lowTotalSeconds = row
            } else {
                parent.highTotalSeconds = row
            }
        }
        
        func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
            return 100
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var lowTotal = 420  // 7:00
        @State private var highTotal = 480 // 8:00
        
        var body: some View {
            MinutesSecondsRangePicker(
                lowTotalSeconds: $lowTotal,
                highTotalSeconds: $highTotal
            )
        }
    }
    
    return PreviewWrapper()
}
