//
//  WorkoutManager.swift
//  Landmarks
//
//  Created by Calvin Korver on 1/6/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import HealthKit
import WatchKit

class WorkoutManager {
    let healthStore = HKHealthStore()
    
    func requestAuthorization() async throws {
        // Define the health data types we want to access
        let typesToWrite: Set = [
            HKObjectType.workoutType(),
            HKSeriesType.workoutRoute(),
            HKObjectType.quantityType(forIdentifier: .heartRate)!
        ]
        
        // Request authorization
        try await healthStore.requestAuthorization(toShare: typesToWrite, read: typesToWrite)
    }
    
    func saveWorkoutToWatch(workout: Workout) async throws {
        // Convert your Workout model to HKWorkoutConfiguration
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .running  // Or other activity type
        configuration.locationType = .outdoor  // Or .indoor
        
        // Create workout builder
        guard let workoutBuilder = try? HKWorkoutBuilder(
            healthStore: healthStore,
            configuration: configuration,
            device: .local()
        ) else {
            throw WorkoutError.failedToCreateBuilder
        }
        
        // Start the workout
        try await workoutBuilder.beginCollection(at: Date())
        
        // Add workout blocks as intervals
        for block in workout.blocks {
            // Create interval event
            let metadata: [String: Any] = [
                HKMetadataKeyWorkoutBrandName: "Your App Name",
                "BlockName": block.name,
                // Add other custom metadata
            ]
            
            let event = HKWorkoutEvent(
                type: .segment,
                date: Date(),
                metadata: metadata
            )
            
            try await workoutBuilder.add([event])
        }
        
        // End workout
        try await workoutBuilder.endCollection(at: Date())
        try await workoutBuilder.finishWorkout()
    }
}
