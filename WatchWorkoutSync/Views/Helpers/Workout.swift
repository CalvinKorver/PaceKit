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
    case custom = "custom"
}

struct Distance: Hashable, Codable {
    var value: Double
    var unit: DistanceUnit
    
    func getUnitShorthand() -> String {
        return distanceShortHand(unit.rawValue)
    }
    
    func getUnit() -> String {
        return unit.rawValue
    }
    
    func getValue() -> Double {
        return value
    }
}


struct Block: Hashable, Codable, Identifiable {
    var id: Int
    var name: String
    var distance: Distance?
    var duration: Duration?
    var paceConstraint: PaceConstraint?
    var type: BlockType
}

struct PaceConstraint:Hashable, Codable, Identifiable {
    var id: Int
    var pace: Int // seconds
}

struct Duration: Hashable, Codable {
    var seconds: Int
}

enum BlockType: Int, Codable {
   case warmup = 1
   case cooldown = 2
   case mainSet = 3
   
   var name: String {
       switch self {
       case .warmup: return "Warmup"
       case .cooldown: return "Cooldown"
       case .mainSet: return "Main Set"
       }
   }
   
   static func fromString(_ string: String) -> BlockType? {
       switch string.lowercased() {
       case "warmup": return .warmup
       case "cooldown": return .cooldown
       case "main set": return .mainSet
       default: return nil
       }
   }
}
