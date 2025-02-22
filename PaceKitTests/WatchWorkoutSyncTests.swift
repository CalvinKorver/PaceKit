//
//  WatchWorkoutSyncTests.swift
//  WatchWorkoutSyncTests
//
//  Created by Calvin Korver on 1/11/25.
//

import Testing
import PaceKit

struct WatchWorkoutSyncTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }
    
    @Test func buildWorkBlockTest() async throws {
        // Arrange
        let workBlock = 
    }
    
    /*
     
     private func buildWorkBlock(from workBlock: WorkBlock) -> IntervalBlock {3
         // Create work step
         let workGoal = createGoalFromBlock(workBlock)
         let workStep = IntervalStep(.work, goal: workGoal, alert: nil)
         
         var intervalSteps: [IntervalStep] = []
         
         // Create recovery step if rest exists
         if let rest = workBlock.restBlock {
             let recoveryGoal = createGoalFromBlock(rest)
             let recoveryStep = IntervalStep(.recovery, goal: recoveryGoal, alert: nil)
             
             // Add both steps to the plan
             intervalSteps = [workStep, recoveryStep]
         } else {
             // Just add the work step if no rest
             intervalSteps = [workStep]
         }
         
         return IntervalBlock(steps: intervalSteps, iterations: workBlock.repeats ?? 1)
     */

}
