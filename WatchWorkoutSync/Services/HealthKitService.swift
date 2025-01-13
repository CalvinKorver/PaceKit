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
        var workoutPlan: WorkoutPlan = switch(workout.type) {
        case .simple:
            try createSimpleWorkoutPlan(workout)
        case .pacer:
            try createPacerWorkoutPlan(workout)
        default :
            throw NSError(domain: "Workout", code: 1, userInfo: nil)
        }
        
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
