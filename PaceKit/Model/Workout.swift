import Foundation
import SwiftUI

// Base Workout model
struct Workout: Hashable, Codable, Identifiable {
    var id: Int
    var name: String
    var blocks: [Block]? // 0..* relationship with Block
    var isFavorite: Bool
    
    private var imageName: String
    var image: Image {
        Image(imageName)
    }
    
    init(id: Int, name: String, blocks: [Block], isFavorite: Bool, imageName: String) {
        self.id = id
        self.name = name
        self.blocks = blocks
        self.isFavorite = isFavorite
        self.imageName = imageName
    }
}
//
//enum WorkoutType: String, CaseIterable, Codable {
//    case simple = "simple"
//    case pacer = "pacer"
//    case custom = "custom"
//}

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
   case work = 3
   case rest = 4
   
   var name: String {
       switch self {
       case .warmup: return "Warmup"
       case .cooldown: return "Cooldown"
       case .work: return "Work"
       case .rest: return "Rest"
       }
   }
}

class Block: Hashable, Codable, Identifiable {
    var id: Int
    var distance: Distance?
    var duration: Duration?
    var metricType: MetricType?
    var blockType: BlockType
    
    enum CodingKeys: String, CodingKey {
        case id, blockType, distance, duration, metricType
    }
    
    init(id: Int, blockType: BlockType, distance: Distance? = nil, duration: Duration? = nil, metricType: MetricType = .distance) {
        self.id = id
        self.distance = distance
        self.duration = duration
        self.metricType = metricType
        self.blockType = blockType
    }
    
    // Factory method for decoding
    static func decode(from decoder: Decoder) throws -> Block {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let blockType = try container.decode(BlockType.self, forKey: .blockType)
        
        switch blockType {
        case .work:
            return try WorkBlock(from: decoder)
        default:
            let block = Block(
                id: try container.decode(Int.self, forKey: .id),
                blockType: blockType,
                distance: try container.decodeIfPresent(Distance.self, forKey: .distance),
                duration: try container.decodeIfPresent(Duration.self, forKey: .duration),
                metricType: try container.decodeIfPresent(MetricType.self, forKey: .metricType) ?? .distance
            )
            return block
        }
    }
    
    required init(from decoder: Decoder) throws {
        // This implementation will only be used for non-work blocks
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        blockType = try container.decode(BlockType.self, forKey: .blockType)
        distance = try container.decodeIfPresent(Distance.self, forKey: .distance)
        duration = try container.decodeIfPresent(Duration.self, forKey: .duration)
        metricType = try container.decodeIfPresent(MetricType.self, forKey: .metricType)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Block, rhs: Block) -> Bool {
        lhs.id == rhs.id &&
        lhs.blockType == rhs.blockType &&
        lhs.distance == rhs.distance &&
        lhs.duration == rhs.duration &&
        lhs.metricType == rhs.metricType
    }
}

class WorkBlock: Block {
    var paceConstraint: PaceConstraint?
    var restBlock: SimpleBlock?
    var repeats: Int?
    
    private enum CodingKeys: String, CodingKey {
        case paceConstraint, rest, repeats
    }
    
    init(id: Int,
         distance: Distance? = nil,
         duration: Duration? = nil,
         metricType: MetricType = .distance,
         paceConstraint: PaceConstraint? = nil,
         rest: SimpleBlock? = nil,
         repeats: Int? = nil) {
        self.paceConstraint = paceConstraint
        self.restBlock = rest
        self.repeats = repeats
        super.init(id: id, blockType: .work, distance: distance, duration: duration, metricType: metricType)
    }
    
    required init(from decoder: Decoder) throws {
        // Decode WorkBlock specific properties
        let container = try decoder.container(keyedBy: CodingKeys.self)
        paceConstraint = try container.decodeIfPresent(PaceConstraint.self, forKey: .paceConstraint)
        restBlock = try container.decodeIfPresent(SimpleBlock.self, forKey: .rest)
        repeats = try container.decodeIfPresent(Int.self, forKey: .repeats)
        
        // Decode Block properties
        let parentContainer = try decoder.container(keyedBy: Block.CodingKeys.self)
        let id = try parentContainer.decode(Int.self, forKey: .id)
        let distance = try parentContainer.decodeIfPresent(Distance.self, forKey: .distance)
        let duration = try parentContainer.decodeIfPresent(Duration.self, forKey: .duration)
        let metricType = try parentContainer.decodeIfPresent(MetricType.self, forKey: .metricType)
        
        super.init(id: id, blockType: .work, distance: distance, duration: duration, metricType: metricType ?? .distance)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(paceConstraint, forKey: .paceConstraint)
        try container.encodeIfPresent(restBlock, forKey: .rest)
        try container.encodeIfPresent(repeats, forKey: .repeats)
    }
    
    override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(paceConstraint)
        hasher.combine(repeats)
        hasher.combine(restBlock)
    }
}

// Extension to make Workout use our factory method
extension Workout {
    private enum CodingKeys: String, CodingKey {
        case id, name, blocks, isFavorite, imageName
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        imageName = try container.decode(String.self, forKey: .imageName)
        isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
        
        // Use Block.decode for each block
        var blocksArray = [Block]()
        var blocksContainer = try container.nestedUnkeyedContainer(forKey: .blocks)
        while !blocksContainer.isAtEnd {
            let blockDecoder = try blocksContainer.superDecoder()
            let block = try Block.decode(from: blockDecoder)
            blocksArray.append(block)
        }
        blocks = blocksArray
    }
}

// SimpleBlock subclass
class SimpleBlock: Block {
    override init(id: Int,
                 blockType: BlockType,
                 distance: Distance? = nil,
                 duration: Duration? = nil,
                 metricType: MetricType = .distance) {
        super.init(id: id, blockType: blockType, distance: distance, duration: duration, metricType: metricType)
    }
    
    required init(from decoder: Decoder) throws {
        // Decode Block properties
        let container = try decoder.container(keyedBy: Block.CodingKeys.self)
        let id = try container.decode(Int.self, forKey: .id)
        let blockType = try container.decode(BlockType.self, forKey: .blockType)
        let distance = try container.decodeIfPresent(Distance.self, forKey: .distance)
        let duration = try container.decodeIfPresent(Duration.self, forKey: .duration)
        let metricType = try container.decodeIfPresent(MetricType.self, forKey: .metricType)
        
        super.init(id: id,
                  blockType: blockType,
                  distance: distance,
                  duration: duration,
                  metricType: metricType ?? .distance)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }
    
    // SimpleBlock inherits hash and equality from Block since it doesn't add any properties
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
