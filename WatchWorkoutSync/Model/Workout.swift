//
//  Workout.swift
//  Run Sync
//
//  Created by Calvin Korver on 1/1/25.
//

import Foundation
import SwiftUI

struct Workout: Hashable, Codable, Identifiable {
    var id: Int
    var name: String
    var type: String
    var blocks: [Block]
    var isFavorite: Bool
    
    init(id: Int, name: String, type: String, blocks: [Block], isFavorite: Bool, imageName: String) {
        self.id = id
        self.name = name
        self.type = type
        self.blocks = blocks
        self.isFavorite = isFavorite
        self.imageName = imageName
    }
    
    private var imageName: String
    var image: Image {
        Image(imageName)
    }
}
