import HealthKit
import WorkoutKit

class HealthKitService {
    private let healthStore = HKHealthStore()
    private let scheduler = WorkoutScheduler.shared
    
    func requestAuthorization() async throws {
        let typesToShare: Set = [
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
        ]
        
        let typesToRead: Set = [
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
        ]
        
        // Request HealthKit authorization
        try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
        
        // Request WorkoutKit scheduling authorization
        try await scheduler.requestAuthorization()
    }
    
    private func createPacerWorkoutPlan(_ workout: Workout) throws -> WorkoutPlan {
        // Ensure we have blocks
        guard let block = workout.blocks?.first else {
            throw NSError(domain: "Workout", code: 1, userInfo: ["message": "No blocks found"])
        }
        
        // For a pacer workout, we need both distance and duration
        guard let distance = block.distance,
              let duration = block.duration else {
            throw NSError(domain: "Workout", code: 1, userInfo: ["message": "Pacer workout requires both distance and duration"])
        }
        
        // Convert distance to the appropriate unit
        let unitLength = calculateUnitLengthFromDistanceUnit(distance.unit)
        let distanceMeasurement = Measurement(value: Double(distance.value), unit: unitLength)
        
        // Convert duration to a measurement
        let durationMeasurement = Measurement(value: Double(duration.seconds), unit: UnitDuration.seconds)
        
        // Create the pacer workout
        let workout = PacerWorkout(
            activity: .running,
            location: .outdoor,
            distance: distanceMeasurement,
            time: durationMeasurement
        )
        
        // Create and return the workout plan
        return WorkoutPlan(
            .pacer(workout),
            id: UUID()
        )
    }
    
    
    func calculateUnitLengthFromDistanceUnit(_ distanceUnit: DistanceUnit) -> UnitLength {
        switch(distanceUnit) {
            case .meters: UnitLength.meters
            case .kilometers: UnitLength.kilometers
            case .miles: UnitLength.miles
            default: .meters  // default fallback
        }
    }
    
    private func createGoalFromBlock(_ block: Block) -> WorkoutGoal {
        if let distance = block.distance {
            let unitLength = calculateUnitLengthFromDistanceUnit(distance.unit)
            return WorkoutGoal.distance(distance.value, unitLength)
        } else if let duration = block.duration {
            return WorkoutGoal.time(Double(duration.seconds), UnitDuration.seconds)
        } else {
            // This shouldn't happen if we validate blocks before calling this method
            fatalError("Block must have either distance or duration")
        }
    }
    
    private func createCustomWorkoutPlan(_ workout: Workout) throws -> WorkoutPlan {
        let workBlock = workout.blocks?.first(where: { $0.blockType == .work}) as? WorkBlock
        let warmupBlock = workout.blocks?.first(where: { $0.blockType == .warmup}) as? Block
        let cooldownBlock = workout.blocks?.first(where: { $0.blockType == .cooldown}) as? Block
        
        guard let workBlock = workBlock else {
            throw WorkoutError.invalidWorkout(message: "No work block found")
        }
        
        // Create work step
        let workGoal = createGoalFromBlock(workBlock)
        let workStep = IntervalStep(.work,
            goal: workGoal,
            alert: nil
        )
        
        let intervalBlock = buildWorkBlock(from: workBlock)
        let warmupStep = buildWorkoutStep(from: warmupBlock)
        let cooldownStep = buildWorkoutStep(from: cooldownBlock)
        
        
        let workout = CustomWorkout(
            activity: .running,
            location: .outdoor,
            displayName: workout.name,
            warmup: warmupStep,
            blocks: [intervalBlock],
            cooldown: cooldownStep
        )
        
        return WorkoutPlan(.custom(workout))
        
    }
    
    private func buildWorkoutStep(from block: Block?) -> WorkoutStep? {
        guard let block = block else { return nil }
        let goal = createGoalFromBlock(block)
        let workStep = WorkoutStep(goal: goal, alert: nil)
        return WorkoutStep(goal: goal, alert: nil)
    }

    private func buildWorkBlock(from workBlock: WorkBlock) -> IntervalBlock {
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
        
        return IntervalBlock(steps: intervalSteps, iterations: 1)
    }
    
    // Define custom error type
    enum WorkoutError: Error {
        case invalidWorkout(message: String)
    }

    
    private func createSimpleWorkoutPlan(_ workout: Workout) throws -> WorkoutPlan {
        let block = workout.blocks?.first
        var workoutGoal: WorkoutGoal
        if let distance = block?.distance {
            let unitLength = calculateUnitLengthFromDistanceUnit(distance.unit)
            workoutGoal = WorkoutGoal.distance(distance.value, unitLength)
        } else if let duration = block?.duration {
            workoutGoal = WorkoutGoal.time(Double(duration.seconds), UnitDuration.seconds)
        } else {
            throw NSError(domain: "Workout", code: 1, userInfo: nil)
        }
        
        let workout =  SingleGoalWorkout(activity: .running,
                                 location: .outdoor,
                                 goal: workoutGoal);
        // Create a workout plan
        return WorkoutPlan(
            .goal(workout),
            id: UUID()
        )
        
    }
    
    func saveWorkout(_ workout: Workout) async throws {
//        var workoutPlan: WorkoutPlan = switch(workout.type) {
//        case .simple:
//            try createSimpleWorkoutPlan(workout)
//        case .pacer:
//            try createPacerWorkoutPlan(workout)
//        case .custom:
//            try createCustomWorkoutPlan(workout)
//        default :
//            throw NSError(domain: "Workout", code: 1, userInfo: nil)
//        }
        
        var workoutPlan = try createCustomWorkoutPlan(workout)
        
        workoutPlan.id = UUID()
        var daysAheadComponents = DateComponents()
        daysAheadComponents.day = 0
        daysAheadComponents.hour = 1
        
        guard let nextDate = Calendar.autoupdatingCurrent.date(byAdding: daysAheadComponents, to: .now) else {
            return
        }
        
        let nextDateComponents = Calendar.autoupdatingCurrent.dateComponents(in: .autoupdatingCurrent, from: nextDate)
        await WorkoutScheduler.shared.schedule(workoutPlan, at: nextDateComponents)
    }
}

// Helper extension to convert your DistanceUnit to WorkoutKit's UnitLength
extension DistanceUnit {
    var workoutUnit: UnitLength {
        switch self {
        case .kilometers:
            return .kilometers
        case .miles:
            return .miles
        case .meters:
            return .meters
        }
    }
}
