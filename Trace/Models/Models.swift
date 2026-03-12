//
//  Models.swift
//  Trace
//
//  All SwiftData models for the app
//

import Foundation
import SwiftData

// MARK: - Exercise Category
enum ExerciseCategory: String, Codable, CaseIterable, Identifiable {
    case upperBody = "Upper Body"
    case lowerBody = "Lower Body"
    case core = "Core"
    case back = "Back"
    case mobility = "Mobility"
    case cardio = "Cardio"
    case fullBody = "Full Body"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .upperBody: return "figure.arms.open"
        case .lowerBody: return "figure.walk"
        case .core: return "figure.core.training"
        case .back: return "figure.rowing"
        case .mobility: return "figure.flexibility"
        case .cardio: return "figure.run"
        case .fullBody: return "figure.strengthtraining.traditional"
        }
    }
}

// MARK: - Workout Type
enum WorkoutType: String, Codable, CaseIterable, Identifiable {
    case strength = "Strength"
    case cardio = "Cardio"
    case yoga = "Yoga"
    case hiit = "HIIT"
    case flexibility = "Flexibility"
    case custom = "Custom"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .strength: return "dumbbell.fill"
        case .cardio: return "figure.run"
        case .yoga: return "figure.yoga"
        case .hiit: return "bolt.fill"
        case .flexibility: return "figure.flexibility"
        case .custom: return "star.fill"
        }
    }
}

// MARK: - Exercise (Pool Item)
@Model
final class Exercise {
    var id: UUID
    var name: String
    var category: ExerciseCategory
    var workoutType: WorkoutType
    var instructions: String
    var isCustom: Bool
    
    init(name: String, category: ExerciseCategory, workoutType: WorkoutType, instructions: String = "", isCustom: Bool = false) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.workoutType = workoutType
        self.instructions = instructions
        self.isCustom = isCustom
    }
}

// MARK: - Exercise Set (within a workout)
@Model
final class ExerciseSet {
    var id: UUID
    var setNumber: Int
    var weight: Double // in kg
    var reps: Int
    var isCompleted: Bool
    var exerciseLog: ExerciseLog?
    
    init(setNumber: Int, weight: Double = 0, reps: Int = 0, isCompleted: Bool = false) {
        self.id = UUID()
        self.setNumber = setNumber
        self.weight = weight
        self.reps = reps
        self.isCompleted = isCompleted
    }
}

// MARK: - Exercise Log (one exercise in a workout session)
@Model
final class ExerciseLog {
    var id: UUID
    var exerciseName: String
    var category: ExerciseCategory
    @Relationship(deleteRule: .cascade) var sets: [ExerciseSet]
    var notes: String
    var workout: Workout?
    
    init(exerciseName: String, category: ExerciseCategory, sets: [ExerciseSet] = [], notes: String = "") {
        self.id = UUID()
        self.exerciseName = exerciseName
        self.category = category
        self.sets = sets
        self.notes = notes
    }
}

// MARK: - Workout Session
@Model
final class Workout {
    var id: UUID
    var name: String
    var workoutType: WorkoutType
    var date: Date
    var duration: TimeInterval // seconds
    var caloriesBurned: Double
    var avgHeartRate: Double
    var maxHeartRate: Double
    var isCompleted: Bool
    var pointsEarned: Int
    @Relationship(deleteRule: .cascade) var exercises: [ExerciseLog]
    
    init(name: String, workoutType: WorkoutType, date: Date = Date()) {
        self.id = UUID()
        self.name = name
        self.workoutType = workoutType
        self.date = date
        self.duration = 0
        self.caloriesBurned = 0
        self.avgHeartRate = 0
        self.maxHeartRate = 0
        self.isCompleted = false
        self.pointsEarned = 0
        self.exercises = []
    }
}

// MARK: - Workout Template
@Model
final class WorkoutTemplate {
    var id: UUID
    var name: String
    var workoutType: WorkoutType
    var targetCategory: ExerciseCategory
    var exerciseNames: [String]
    var defaultSets: Int
    var defaultReps: Int
    var lastUsedDate: Date?
    var usageCount: Int
    
    init(name: String, workoutType: WorkoutType, targetCategory: ExerciseCategory, exerciseNames: [String], defaultSets: Int = 3, defaultReps: Int = 10) {
        self.id = UUID()
        self.name = name
        self.workoutType = workoutType
        self.targetCategory = targetCategory
        self.exerciseNames = exerciseNames
        self.defaultSets = defaultSets
        self.defaultReps = defaultReps
        self.usageCount = 0
    }
}

// MARK: - User Profile
@Model
final class UserProfile {
    var id: UUID
    var displayName: String
    var username: String
    var bio: String
    var totalPoints: Int
    var totalWorkouts: Int
    var currentStreak: Int
    var longestStreak: Int
    var streakGoal: Int // workouts per week
    var joinDate: Date
    var lastWorkoutDate: Date?
    
    init(displayName: String, username: String) {
        self.id = UUID()
        self.displayName = displayName
        self.username = username
        self.bio = ""
        self.totalPoints = 0
        self.totalWorkouts = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.streakGoal = 4
        self.joinDate = Date()
    }
}

// MARK: - Group
@Model
final class WorkoutGroup {
    var id: UUID
    var name: String
    var groupDescription: String
    var minWorkoutsPerWeek: Int
    var memberNames: [String] // simplified - just names for now
    var weeklyPoints: Int
    var totalPoints: Int
    var createdDate: Date
    
    init(name: String, description: String = "", minWorkoutsPerWeek: Int = 3) {
        self.id = UUID()
        self.name = name
        self.groupDescription = description
        self.minWorkoutsPerWeek = minWorkoutsPerWeek
        self.memberNames = []
        self.weeklyPoints = 0
        self.totalPoints = 0
        self.createdDate = Date()
    }
    
    var weeklyGoal: Int {
        memberNames.count * minWorkoutsPerWeek
    }
}

// MARK: - Community
@Model
final class Community {
    var id: UUID
    var name: String
    var communityDescription: String
    var memberCount: Int
    var isPublic: Bool
    var createdDate: Date
    @Relationship(deleteRule: .cascade) var events: [CommunityEvent]
    
    init(name: String, description: String = "", isPublic: Bool = true) {
        self.id = UUID()
        self.name = name
        self.communityDescription = description
        self.memberCount = 1
        self.isPublic = isPublic
        self.createdDate = Date()
        self.events = []
    }
}

// MARK: - Community Event
@Model
final class CommunityEvent {
    var id: UUID
    var name: String
    var eventDescription: String
    var startDate: Date
    var endDate: Date
    var isOnline: Bool
    var participantCount: Int
    var community: Community?
    
    init(name: String, description: String = "", startDate: Date, endDate: Date, isOnline: Bool = true) {
        self.id = UUID()
        self.name = name
        self.eventDescription = description
        self.startDate = startDate
        self.endDate = endDate
        self.isOnline = isOnline
        self.participantCount = 0
    }
}

// MARK: - Leaderboard Entry
@Model
final class LeaderboardEntry {
    var id: UUID
    var playerName: String
    var points: Int
    var rank: Int
    var region: String
    var isGroup: Bool
    
    init(playerName: String, points: Int, rank: Int, region: String = "Global", isGroup: Bool = false) {
        self.id = UUID()
        self.playerName = playerName
        self.points = points
        self.rank = rank
        self.region = region
        self.isGroup = isGroup
    }
}
