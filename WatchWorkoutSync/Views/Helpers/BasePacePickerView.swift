import SwiftUI

struct BasePickerView: UIViewRepresentable {
    @Binding var primaryValue: Int
    @Binding var secondaryValue: Int
    let primaryRange: [Int]
    let secondaryRange: [Int]
    let label: String
    let primaryFormat: String
    let secondaryFormat: String
    let separator: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UIPickerView {
        let picker = UIPickerView()
        picker.delegate = context.coordinator
        picker.dataSource = context.coordinator
        
        // Center the picker
        picker.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        picker.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        // Set initial selection
        if let primaryIndex = primaryRange.firstIndex(of: primaryValue) {
            picker.selectRow(primaryIndex, inComponent: 0, animated: false)
        }
        if let secondaryIndex = secondaryRange.firstIndex(of: secondaryValue) {
            picker.selectRow(secondaryIndex, inComponent: 2, animated: false)
        }
        
        return picker
    }
    
    func updateUIView(_ uiView: UIPickerView, context: Context) {
        if let primaryIndex = primaryRange.firstIndex(of: primaryValue) {
            uiView.selectRow(primaryIndex, inComponent: 0, animated: true)
        }
        if let secondaryIndex = secondaryRange.firstIndex(of: secondaryValue) {
            uiView.selectRow(secondaryIndex, inComponent: 2, animated: true)
        }
    }
    
    class Coordinator: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
        var parent: BasePickerView
        
        init(_ pickerView: BasePickerView) {
            self.parent = pickerView
        }
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 4  // Primary, Separator, Secondary, Label
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            switch component {
            case 0:  // Primary
                return parent.primaryRange.count
            case 1:  // Separator
                return 1
            case 2:  // Secondary
                return parent.secondaryRange.count
            case 3:  // Label
                return 1
            default:
                return 0
            }
        }
        
        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            let containerView = UIView()
            let label = (view as? UILabel) ?? UILabel()
            label.font = .systemFont(ofSize: 20, weight: .medium)
            
            switch component {
            case 0:  // Primary
                let value = parent.primaryRange[row]
                label.text = String(format: parent.primaryFormat, value)
                label.textAlignment = .right
                containerView.addSubview(label)
                
            case 1:  // Separator
                label.text = parent.separator
                label.textAlignment = .center
                containerView.addSubview(label)
                label.frame = containerView.bounds
            case 2:  // Secondary
                let value = parent.secondaryRange[row]
                label.text = String(format: parent.secondaryFormat, value)
                label.textAlignment = .left
                containerView.addSubview(label)
                
            case 3:  // Label
                label.text = parent.label
                label.textAlignment = .left
                label.textColor = .secondaryLabel
                containerView.addSubview(label)
                
            default:
                break
            }
            
            label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            return containerView
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            switch component {
            case 0:
                parent.primaryValue = parent.primaryRange[row]
            case 2:
                parent.secondaryValue = parent.secondaryRange[row]
            default:
                break
            }
        }
        
        func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
            switch component {
            case 0: return 40  // Primary
            case 1: return 15  // Separator
            case 2: return 40  // Secondary
            case 3: return 65  // Label
            default: return 0
            }
        }
    }
}
