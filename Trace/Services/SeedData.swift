//
//  SeedData.swift
//  Trace
//
//  Pre-loaded exercise pool and sample data
//

import Foundation
import SwiftData

struct SeedData {
    
    // MARK: - Exercise Pool
    static let exercises: [(String, ExerciseCategory, WorkoutType)] = [
        // Upper Body - Strength
        ("Bench Press", .upperBody, .strength),
        ("Overhead Press", .upperBody, .strength),
        ("Incline Dumbbell Press", .upperBody, .strength),
        ("Dumbbell Flyes", .upperBody, .strength),
        ("Lateral Raises", .upperBody, .strength),
        ("Front Raises", .upperBody, .strength),
        ("Tricep Dips", .upperBody, .strength),
        ("Tricep Pushdown", .upperBody, .strength),
        ("Bicep Curls", .upperBody, .strength),
        ("Hammer Curls", .upperBody, .strength),
        ("Push Ups", .upperBody, .strength),
        ("Diamond Push Ups", .upperBody, .strength),
        ("Arnold Press", .upperBody, .strength),
        ("Cable Crossover", .upperBody, .strength),
        ("Skull Crushers", .upperBody, .strength),
        
        // Lower Body - Strength
        ("Barbell Squat", .lowerBody, .strength),
        ("Romanian Deadlift", .lowerBody, .strength),
        ("Leg Press", .lowerBody, .strength),
        ("Lunges", .lowerBody, .strength),
        ("Bulgarian Split Squat", .lowerBody, .strength),
        ("Leg Extension", .lowerBody, .strength),
        ("Leg Curl", .lowerBody, .strength),
        ("Calf Raises", .lowerBody, .strength),
        ("Hip Thrust", .lowerBody, .strength),
        ("Goblet Squat", .lowerBody, .strength),
        ("Sumo Deadlift", .lowerBody, .strength),
        ("Step Ups", .lowerBody, .strength),
        
        // Back - Strength
        ("Deadlift", .back, .strength),
        ("Pull Ups", .back, .strength),
        ("Barbell Row", .back, .strength),
        ("Lat Pulldown", .back, .strength),
        ("Seated Cable Row", .back, .strength),
        ("Face Pulls", .back, .strength),
        ("Single Arm Dumbbell Row", .back, .strength),
        ("T-Bar Row", .back, .strength),
        ("Chin Ups", .back, .strength),
        ("Shrugs", .back, .strength),
        
        // Core
        ("Plank", .core, .strength),
        ("Russian Twists", .core, .strength),
        ("Hanging Leg Raises", .core, .strength),
        ("Cable Crunches", .core, .strength),
        ("Ab Wheel Rollout", .core, .strength),
        ("Mountain Climbers", .core, .strength),
        ("Dead Bugs", .core, .strength),
        ("Bird Dogs", .core, .strength),
        ("Side Plank", .core, .strength),
        ("Bicycle Crunches", .core, .strength),
        
        // Cardio
        ("Running", .cardio, .cardio),
        ("Cycling", .cardio, .cardio),
        ("Rowing Machine", .cardio, .cardio),
        ("Jump Rope", .cardio, .cardio),
        ("Stair Climber", .cardio, .cardio),
        ("Swimming", .cardio, .cardio),
        ("Elliptical", .cardio, .cardio),
        ("Burpees", .fullBody, .hiit),
        ("Box Jumps", .fullBody, .hiit),
        ("Battle Ropes", .fullBody, .hiit),
        
        // Mobility / Yoga
        ("Downward Dog", .mobility, .yoga),
        ("Warrior I", .mobility, .yoga),
        ("Warrior II", .mobility, .yoga),
        ("Child's Pose", .mobility, .yoga),
        ("Cat-Cow Stretch", .mobility, .yoga),
        ("Pigeon Pose", .mobility, .yoga),
        ("Hip Flexor Stretch", .mobility, .flexibility),
        ("Hamstring Stretch", .mobility, .flexibility),
        ("Shoulder Stretch", .mobility, .flexibility),
        ("Foam Rolling", .mobility, .flexibility),
    ]
    
    static func seedExercises(context: ModelContext) {
        // Check if already seeded
        let descriptor = FetchDescriptor<Exercise>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }
        
        for (name, category, type) in exercises {
            let exercise = Exercise(name: name, category: category, workoutType: type)
            context.insert(exercise)
        }
        
        try? context.save()
    }
    
    static func seedSampleProfile(context: ModelContext) {
        let descriptor = FetchDescriptor<UserProfile>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }
        
        let profile = UserProfile(displayName: "Athlete", username: "athlete1")
        profile.streakGoal = 4
        context.insert(profile)
        try? context.save()
    }
    
    // Generate sample leaderboard data
    static func seedLeaderboard(context: ModelContext) {
        let descriptor = FetchDescriptor<LeaderboardEntry>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }
        
        let names = ["Alex W.", "Jordan M.", "Sam K.", "Taylor B.", "Morgan R.", "Casey L.", "Riley P.", "Avery T.", "Quinn S.", "Drew N."]
        
        for (index, name) in names.enumerated() {
            let points = Int.random(in: 500...5000)
            let entry = LeaderboardEntry(playerName: name, points: points, rank: index + 1)
            context.insert(entry)
        }
        
        try? context.save()
    }
}
