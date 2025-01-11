//
//  BlockViewModel.swift
//  Landmarks
//
//  Created by Calvin Korver on 1/8/25.
//  Copyright © 2025 Apple. All rights reserved.
//
import SwiftUI

// BlockViewModel.swift
struct BlockViewModel {
    private let block: Block
    
    init(block: Block) {
        self.block = block
    }
    
    var name: String {
        block.name
    }
    
    var isMainBlock: Bool {
        block.name.contains("Main")
    }
    
    var distanceText: String? {
        guard let distance = block.distance else { return nil }
        let unit = switch(block.distanceUnit) {
            case .meters: "meters"
            case .none: "meters"
            case .miles: "miles"
            case .kilometers: "km"
        }
        return "\(distance) \(unit)"
    }
    
    var durationText: String? {
        guard let duration = block.durationSeconds else { return nil }
        if duration >= 60 {
            return "\(duration / 60) minutes"
        } else {
            return "\(duration) seconds"
        }
    }
    
    var paceText: String? {
        guard let pace = block.paceConstraint else { return nil }
        let lowMins = getMins(minSecs: pace.paceLow)
        let lowSecs = getSecs(minSecs: pace.paceLow)
        let highMins = getMins(minSecs: pace.paceHigh)
        let highSecs = getSecs(minSecs: pace.paceLow)
        
        return "\(lowMins):\(lowSecs) - \(highMins):\(highSecs) min/mil"
    }
}
