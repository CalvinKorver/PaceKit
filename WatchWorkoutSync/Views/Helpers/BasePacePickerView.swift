import SwiftUI

struct BasePacePickerView: UIViewRepresentable {
    @Binding var selectedSeconds: Int
    let secondsLow: Int
    let secondsHigh: Int
    let incrementSeconds: Int
    let label: String
    
    // Calculate number of rows based on input parameters
    private var numberOfRows: Int {
        // Add 1 to include both min and max values
        return ((secondsHigh - secondsLow) / incrementSeconds) + 1
    }
    
    // Convert picker row to actual seconds value
    private func secondsFromRow(_ row: Int) -> Int {
        return secondsLow + (row * incrementSeconds)
    }
    
    // Convert seconds value to picker row
    private func rowFromSeconds(_ seconds: Int) -> Int {
        // Clamp the seconds value to our valid range
        let clampedSeconds = min(max(seconds, secondsLow), secondsHigh)
        return (clampedSeconds - secondsLow) / incrementSeconds
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UIPickerView {
        let picker = UIPickerView()
        picker.delegate = context.coordinator
        picker.dataSource = context.coordinator
        
        // Set initial selection
        let initialRow = rowFromSeconds(selectedSeconds)
        picker.selectRow(initialRow, inComponent: 0, animated: false)
        

        
        return picker
    }
    
    func updateUIView(_ uiView: UIPickerView, context: Context) {
        let currentRow = rowFromSeconds(selectedSeconds)
        uiView.selectRow(currentRow, inComponent: 0, animated: true)
    }
    
    class Coordinator: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
        var parent: BasePacePickerView
        
        init(_ pickerView: BasePacePickerView) {
            self.parent = pickerView
        }
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 2  // One for time, one for label
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return component == 0 ? parent.numberOfRows : 1
        }
        
        func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
            28
        }
        
        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            let label = (view as? UILabel) ?? UILabel()
            
            if component == 0 {
                let totalSeconds = parent.secondsFromRow(row)
                let minutes = totalSeconds / 60
                let seconds = totalSeconds % 60
                label.text = String(format: "%d:%02d", minutes, seconds)
                label.textAlignment = .right
                label.font = .systemFont(ofSize: 20, weight: .medium)
            } else {
                label.text = parent.label
                label.textAlignment = .left
                label.font = .systemFont(ofSize: 20, weight: .regular)
                label.textColor = .secondaryLabel
            }
            
            return label
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            if component == 0 {
                parent.selectedSeconds = parent.secondsFromRow(row)
            }
        }
        
        func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
            return 100
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedSeconds = 420  // 7 minutes
        
        var body: some View {
            BasePacePickerView(
                selectedSeconds: $selectedSeconds,
                secondsLow: 360,   // 6:00
                secondsHigh: 780,  // 13:00
                incrementSeconds: 5,
                label: " mins/mile"
            )
        }
    }
    
    return PreviewWrapper()
}
