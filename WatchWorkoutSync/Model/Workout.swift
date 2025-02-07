import Foundation
import SwiftUI

// Base Workout model
struct Workout: Hashable, Codable, Identifiable {
    var id: Int
    var name: String
    var type: WorkoutType
    var blocks: [Block]? // 0..* relationship with Block
    var isFavorite: Bool
    
    private var imageName: String
    var image: Image {
        Image(imageName)
    }
    
    init(id: Int, name: String, type: String, blocks: [Block], isFavorite: Bool, imageName: String) {
        self.id = id
        self.name = name
        self.type = WorkoutType(rawValue: type)!
        self.blocks = blocks
        self.isFavorite = isFavorite
        self.imageName = imageName
    }
}

enum WorkoutType: String, CaseIterable, Codable {
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
}

// Base Block class
class Block: Hashable, Codable, Identifiable {
    var id: Int
    var distance: Distance?
    var duration: Duration?
    
    init(id: Int, distance: Distance? = nil, duration: Duration? = nil) {
        self.id = id
        self.distance = distance
        self.duration = duration
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Block, rhs: Block) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Required for class inheritance with Codable
    private enum CodingKeys: String, CodingKey {
        case id, distance, duration
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        distance = try container.decodeIfPresent(Distance.self, forKey: .distance)
        duration = try container.decodeIfPresent(Duration.self, forKey: .duration)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(distance, forKey: .distance)
        try container.encodeIfPresent(duration, forKey: .duration)
    }
}

// WorkBlock subclass
class WorkBlock: Block {
    var paceConstraint: PaceConstraint? // 0..1 relationship with PaceConstraint
    var rest: CooldownBlock? // Warmup as shown in diagram
    var repeats: Int?
    
    private enum CodingKeys: String, CodingKey {
        case paceConstraint, rest, repeats
    }
    
    init(id: Int, distance: Distance? = nil, duration: Duration? = nil,
         paceConstraint: PaceConstraint? = nil, rest: CooldownBlock? = nil, repeats: Int? = nil) {
        self.paceConstraint = paceConstraint
        self.rest = rest
        self.repeats = repeats
        super.init(id: id, distance: distance, duration: duration)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        paceConstraint = try container.decodeIfPresent(PaceConstraint.self, forKey: .paceConstraint)
        rest = try container.decodeIfPresent(CooldownBlock.self, forKey: .rest)
        repeats = try container.decodeIfPresent(Int.self, forKey: .repeats)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(paceConstraint, forKey: .paceConstraint)
        try container.encodeIfPresent(rest, forKey: .rest)
        try container.encodeIfPresent(repeats, forKey: .repeats)
    }
}

// SimpleBlock subclass
class WarmupBlock: Block {
    override init(id: Int, distance: Distance? = nil, duration: Duration? = nil) {
        super.init(id: id, distance: distance, duration: duration)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    // Additional SimpleBlock-specific properties can be added here
}

// SimpleBlock subclass
class CooldownBlock: Block {
    override init(id: Int, distance: Distance? = nil, duration: Duration? = nil) {
        super.init(id: id, distance: distance, duration: duration)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    // Additional SimpleBlock-specific properties can be added here
}

// PaceConstraint class
struct PaceConstraint: Hashable, Codable {
    var duration: Int
    var unit: DistanceType
    
    enum DistanceType: String, Codable {
        case kilometers
        case miles
        case meters
    }
}
