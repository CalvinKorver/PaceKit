//
//  WatchWorkoutSyncTests.swift
//  WatchWorkoutSyncTests
//
//  Created by Calvin Korver on 1/11/25.
//

import Testing
import PaceKit
import WorkoutKit
@testable import PaceKit
import SwiftUI // Make sure this matches your main target name


struct PaceKitTests {

    @Test func createGoalFromBlockWithDistanceBuildsWorkoutGoal() async throws {
        // Arrange
        let block = Block(id: 1, blockType: .work, distance: Distance(value: 5, unit: .miles))
        let sut = HealthKitService()
        let expected = WorkoutGoal.distance(5, UnitLength.miles)
        
        // Act
        let actual: WorkoutGoal = sut.createGoalFromBlock(block)
        
        // Assert
        #expect(actual == expected)
    }
    
    @Test func createGoalFromBlockWithDurationBuildsWorkoutGoal() async throws {
        // Arrange
        let block = Block(id: 1, blockType: .work, distance: nil, duration: Duration(seconds: 300))
        let sut = HealthKitService()
        let expected = WorkoutGoal.time(300, .seconds)
        
        // Act
        let actual: WorkoutGoal = sut.createGoalFromBlock(block)
        
        // Assert
        #expect(actual == expected)
    }
    
    @Test func createGoalWithPaceSavesPace() async throws {
        // Arrange
        let block = Block(id: 1, blockType: .work, distance: nil, duration: Duration(seconds: 300))
        let sut = HealthKitService()
        let expected = WorkoutGoal.time(300, .seconds)
        
        // Act
        let actual: WorkoutGoal = sut.createGoalFromBlock(block)
        
        // Assert
        #expect(actual == expected)
    }

}
