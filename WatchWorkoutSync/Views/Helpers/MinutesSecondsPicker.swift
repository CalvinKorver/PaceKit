//
//  MinutesSecondsPicker.swift
//  Landmarks
//
//  Created by Calvin Korver on 1/9/25.
//  Copyright © 2025 Apple. All rights reserved.
//
import SwiftUI

struct MinutesSecondsPicker: UIViewRepresentable {
    @Binding var distance: Int       // Distance in meters
    @Binding var durationSeconds: Int
    let distanceUnit: String        // "meters", "kilometers", or "miles"
    // Constants for pace range
    private let minPaceSeconds = 360  // 6:00
    private let maxPaceSeconds = 780  // 13:00
    private let incrementSeconds = 5   // 5-second increments
    
    // Calculate number of rows
    private var numberOfRows: Int {
        // Add 1 to include both min and max values
        return ((maxPaceSeconds - minPaceSeconds) / incrementSeconds) + 1
    }
    
    // Convert picker row to actual seconds value
    private func secondsFromRow(_ row: Int) -> Int {
        return minPaceSeconds + (row * incrementSeconds)
    }
    
    // Convert seconds value to picker row
    private func rowFromSeconds(_ seconds: Int) -> Int {
        return (seconds - minPaceSeconds) / incrementSeconds
    }
    
    // Calculate initial pace in seconds per mile
    private var paceInSeconds: Int {
        get {
            let distanceInMiles = switch distanceUnit {
                case "miles": Double(distance)
                case "kilometers": Double(distance) * 0.621371
                default: Double(distance) * 0.000621371 // meters to miles
            }
            
            guard distanceInMiles > 0 else { return 0 }
            return Int(Double(durationSeconds) / distanceInMiles)
        }
        set {
            // When pace changes, update duration based on distance
            let distanceInMiles = switch distanceUnit {
                case "miles": Double(distance)
                case "kilometers": Double(distance) * 0.621371
                default: Double(distance) * 0.000621371 // meters to miles
            }
            
            durationSeconds = Int(distanceInMiles * Double(newValue))
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UIPickerView {
        let picker = UIPickerView()
        picker.delegate = context.coordinator
        picker.dataSource = context.coordinator
        
        // Set initial selection based on calculated pace
        let initialRow = rowFromSeconds(durationSeconds)
        picker.selectRow(paceInSeconds, inComponent: 0, animated: false)
        
        return picker
    }
    
    func updateUIView(_ uiView: UIPickerView, context: Context) {
        let currentRow = rowFromSeconds(durationSeconds)
        uiView.selectRow(currentRow, inComponent: 0, animated: true)
    }
    
    class Coordinator: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
        var parent: MinutesSecondsPicker
        
        init(_ pickerView: MinutesSecondsPicker) {
            self.parent = pickerView
        }
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return parent.numberOfRows
        }
        
        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            let label = (view as? UILabel) ?? UILabel()
            
            let totalSeconds = parent.secondsFromRow(row)
            let minutes = totalSeconds / 60
            let seconds = totalSeconds % 60
            label.text = String(format: "%d:%02d", minutes, seconds)
            label.textAlignment = .center
            label.font = .monospacedSystemFont(ofSize: 20, weight: .medium)
            
            return label
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            parent.durationSeconds = parent.secondsFromRow(row)
        }
        
        func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
            return 100 // Wider to accommodate "min/mile" text
        }


    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var distance = 1609 // 1 mile in meters
        @State private var duration = 420  // 7 minutes
        
        var body: some View {
            MinutesSecondsPicker(
                distance: $distance,
                durationSeconds: $duration,
                distanceUnit: "meters"
            )
        }
    }
    
    return PreviewWrapper()
}
