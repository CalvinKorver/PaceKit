//
//  Workout.swift
//  Run Sync
//
//  Created by Calvin Korver on 1/1/25.
//

import Foundation
import SwiftUI
import WorkoutKit

struct Workout: Hashable, Codable, Identifiable {
    var id: Int
    var name: String
    var type: WorkoutType
    var blocks: [Block]?
    var isFavorite: Bool
     
    init(id: Int, name: String, type: String, blocks: [Block], isFavorite: Bool, imageName: String) {
        self.id = id
        self.name = name
        self.type = WorkoutType(rawValue: type)!
        self.blocks = blocks
        self.isFavorite = isFavorite
        self.imageName = imageName
    }
    
    private var imageName: String
    var image: Image {
        Image(imageName)
    }
}

enum WorkoutType: String, CaseIterable, Decodable, Encodable {
    case simple = "simple"
    case pacer = "pacer"
}

struct Distance: Hashable, Codable {
    var value: Double
    var unit: DistanceUnit
}


struct Block: Hashable, Codable, Identifiable {
    var id: Int
    var name: String
    var distance: Distance?
    var duration: Duration?
    var paceConstraint: PaceConstraint?
}

struct PaceConstraint:Hashable, Codable, Identifiable {
    var id: Int
    var pace: Int // seconds
}

struct Duration: Hashable, Codable {
    var seconds: Int
}

