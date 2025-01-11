//
//  Block.swift
//  Run Sync
//
//  Created by Calvin Korver on 1/1/25.
//

import Foundation

struct Block: Hashable, Codable, Identifiable {
    var id: Int
    var name: String
    var distance: Float?
    var durationSeconds: Int?
    var distanceUnit: DistanceUnit?
    var paceConstraint: PaceConstraint?
}

struct PaceConstraint: Hashable, Codable {
    var id: Int
    var paceLow: Int
    var paceHigh: Int
}
