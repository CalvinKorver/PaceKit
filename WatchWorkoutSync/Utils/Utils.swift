//
//  Utils.swift
//  Landmarks
//
//  Created by Calvin Korver on 1/8/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import SwiftUI

func getMins(minSecs: Int) -> String  {
    return String(minSecs/60);
}

func getSecs(minSecs: Int) -> String {
    let secs = minSecs % 60
    if (secs < 10) {
        return "0" + String(secs)
    }
    return String(secs)
}


// Helper functions for time formatting
func formatSecondsToMMSS(_ totalSeconds: Int) -> String {
    let minutes = totalSeconds / 60
    let seconds = totalSeconds % 60
    return String(format: "%02d:%02d", minutes, seconds)
}

func formatSecondsToMinutesSeconds(_ seconds: Int) -> String {
    let minutes = seconds / 60
    let remainingSeconds = seconds % 60
    return String(format: "%d:%02d", minutes, remainingSeconds)
}

func parseMinutesSeconds(_ timeString: String) -> Int? {
    let components = timeString.split(separator: ":")
    if components.count == 2,
       let minutes = Int(components[0]),
       let seconds = Int(components[1]) {
        return minutes * 60 + seconds
    }
    return nil
}
