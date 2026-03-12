//
//  WorkoutService.swift
//  Trace
//
//  Handles workout logic: progressive overload, template rotation
//

import Foundation
import SwiftData

struct WorkoutService {
    
    // MARK: - Progressive Overload
    // Get the last logged weight/reps for an exercise to suggest progression
    static func getLastPerformance(exerciseName: String, context: ModelContext) -> (weight: Double, reps: Int)? {
        var descriptor = FetchDescriptor<ExerciseLog>(
            predicate: #Predicate { $0.exerciseName == exerciseName },
            sortBy: [SortDescriptor(\ExerciseLog.workout?.date, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        
        guard let lastLog = try? context.fetch(descriptor).first,
              let lastSet = lastLog.sets.sorted(by: { $0.setNumber < $1.setNumber }).last,
              lastSet.weight > 0 else {
            return nil
        }
        
        return (lastSet.weight, lastSet.reps)
    }
    
    // Suggest next weight/reps based on progressive overload
    static func suggestProgression(lastWeight: Double, lastReps: Int, targetReps: Int = 10) -> (weight: Double, reps: Int) {
        // If they hit target reps, increase weight by 2.5kg
        if lastReps >= targetReps {
            return (lastWeight + 2.5, targetReps)
        }
        // Otherwise keep same weight, aim for +1 rep
        return (lastWeight, min(lastReps + 1, targetReps))
    }
    
    // MARK: - Template Generation with Rotation
    // Pick exercises for a category, rotating from the pool to keep things fresh
    static func generateWorkoutExercises(
        category: ExerciseCategory,
        recentExerciseNames: [String],
        allExercises: [Exercise],
        count: Int = 5
    ) -> [Exercise] {
        // Filter exercises in this category
        let categoryExercises = allExercises.filter { $0.category == category }
        
        // Prefer exercises NOT used recently
        let fresh = categoryExercises.filter { !recentExerciseNames.contains($0.name) }
        let pool = fresh.isEmpty ? categoryExercises : fresh
        
        // Shuffle and pick
        return Array(pool.shuffled().prefix(count))
    }
    
    // Get recently used exercise names (last 2 weeks)
    static func getRecentExerciseNames(context: ModelContext) -> [String] {
        let twoWeeksAgo = Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date()
        let descriptor = FetchDescriptor<ExerciseLog>(
            predicate: #Predicate { log in
                log.workout != nil && log.workout!.date > twoWeeksAgo
            }
        )
        
        let logs = (try? context.fetch(descriptor)) ?? []
        return logs.map { $0.exerciseName }
    }
    
    // MARK: - Points Calculation
    static func calculatePoints(for workout: Workout) -> Int {
        var points = 10 // base points for completing a workout
        
        // Bonus for duration (1 point per 5 min)
        points += Int(workout.duration / 300)
        
        // Bonus for exercises completed
        points += workout.exercises.count * 2
        
        // Bonus for completing all sets
        let allSets = workout.exercises.flatMap { $0.sets }
        let completedSets = allSets.filter { $0.isCompleted }
        if !allSets.isEmpty && completedSets.count == allSets.count {
            points += 5 // completion bonus
        }
        
        return points
    }
    
    // MARK: - Streak Tracking
    static func updateStreak(profile: UserProfile, workouts: [Workout]) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Get this week's workout count
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        let thisWeekWorkouts = workouts.filter { $0.date >= startOfWeek && $0.isCompleted }
        
        // Check if yesterday or today had a workout (for streak)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let hasRecentWorkout = workouts.contains { workout in
            let workoutDay = calendar.startOfDay(for: workout.date)
            return (workoutDay == today || workoutDay == yesterday) && workout.isCompleted
        }
        
        if hasRecentWorkout {
            if thisWeekWorkouts.count >= profile.streakGoal {
                profile.currentStreak += 1
                profile.longestStreak = max(profile.longestStreak, profile.currentStreak)
            }
        }
    }
}
