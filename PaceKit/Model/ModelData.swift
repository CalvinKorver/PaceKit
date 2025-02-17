/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Storage for model data.
*/


import Foundation
import SwiftUI

@Observable
class ModelData {
    var workouts: [Workout] = load("workoutData.json") {
        didSet {
            print("ModelData workouts updated:")
            print("Total workouts: \(workouts.count)")
            for workout in workouts {
                print("\nWorkout: \(workout.name) (ID: \(workout.id))")
                if let blocks = workout.blocks {
                    print("Blocks: \(blocks.count)")
                    for block in blocks {
                        print("- Block ID: \(block.id)")
                        print("  Distance: \(String(describing: block.distance))")
                        print("  Duration: \(String(describing: block.duration))")
                    }
                } else {
                    print("No blocks")
                }
            }
        }
    }
}

// Debug the load function
func load<T: Decodable>(_ filename: String) -> T {
    print("Loading data from \(filename)")
    let data: Data

    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else {
            print("Could not find \(filename) in main bundle")
            fatalError("Couldn't find \(filename) in main bundle.")
    }

    do {
        data = try Data(contentsOf: file)
        print("Successfully loaded data from file")
    } catch {
        print("Error loading data: \(error)")
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }

    do {
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(T.self, from: data)
        print("Successfully decoded data")
        return decoded
    } catch {
        print("Error decoding data: \(error)")
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}
