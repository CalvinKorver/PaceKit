//
//  BlockEditViewModel.swift
//  Landmarks
//
//  Created by Calvin Korver on 1/8/25.
//  Copyright © 2025 Apple. All rights reserved.
//
import SwiftUI

// BlockEditViewModel.swift
class BlockEditViewModel: ObservableObject {
    @Published var blockState: BlockEditState
    @Published var selectedMetric: MetricType = .time
    @Published var showPaceConstraint = false
    @Published var distanceString = ""
    @Published var durationString = ""
    @Published var selectedDistanceUnit = DistanceUnit.miles
    @Published var lowTotalSeconds: Int = 300  // 5:00
    @Published var highTotalSeconds: Int = 360 // 6:00
    
    // Helper to format seconds to MM:SS string
    func formatSecondsToMMSS(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func updatePaceConstraint() {
        blockState.block.paceConstraint = PaceConstraint(
            id: blockState.block.id,
            paceLow: lowTotalSeconds,
            paceHigh: highTotalSeconds
        )
    }
    
    enum MetricType: String, CaseIterable {
        case distance = "Distance"
        case time = "Time"
    }
    
    init(blockState: BlockEditState) {
        self.blockState = blockState
        initializeFields()
    }
    
    func initializeFields() {
        if let distance = blockState.block.distance {
            distanceString = String(distance)
        }
        if let duration = blockState.block.durationSeconds {
            durationString = formatSecondsToMinutesSeconds(duration)
        }
        if let unit = blockState.block.distanceUnit {
            selectedDistanceUnit = unit
            selectedMetric = .distance
        }
    }
    
    
    private func secondsToDate(_ seconds: Int) -> Date {
        let calendar = Calendar.current
        let midnight = calendar.startOfDay(for: Date())
        return calendar.date(byAdding: .second, value: seconds, to: midnight) ?? midnight
    }
    
    private func dateToSeconds(_ date: Date) -> Int {
        let calendar = Calendar.current
        let midnight = calendar.startOfDay(for: date)
        let components = calendar.dateComponents([.minute, .second], from: midnight, to: date)
        return (components.minute ?? 0) * 60 + (components.second ?? 0)
    }
    
    var blockName: String {
        get { blockState.block.name }
        set { blockState.block.name = newValue }
    }
    
    func clearOtherMetric(_ newType: MetricType) {
        if newType == .distance {
            blockState.block.durationSeconds = nil
            durationString = ""
        } else {
            blockState.block.distance = nil
            blockState.block.distanceUnit = nil
            distanceString = ""
        }
    }
    
    func updateDistance() {
        if let distance = Float(distanceString) {
            blockState.block.distance = distance
            blockState.block.distanceUnit = selectedDistanceUnit
        } else {
            blockState.block.distance = nil
            blockState.block.distanceUnit = nil
        }
    }
    
    func updateDuration() {
        blockState.block.durationSeconds = Int(durationString)
    }
    
    
    private func formatSecondsToMinutesSeconds(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    private func parseMinutesSeconds(_ timeString: String) -> Int? {
        let components = timeString.split(separator: ":")
        if components.count == 2,
           let minutes = Int(components[0]),
           let seconds = Int(components[1]) {
            return minutes * 60 + seconds
        }
        return nil
    }
}
