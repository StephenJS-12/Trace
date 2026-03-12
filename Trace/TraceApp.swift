//
//  TraceApp.swift
//  Trace
//

import SwiftUI
import SwiftData

@main
struct TraceApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Exercise.self,
            ExerciseSet.self,
            ExerciseLog.self,
            Workout.self,
            WorkoutTemplate.self,
            UserProfile.self,
            WorkoutGroup.self,
            Community.self,
            CommunityEvent.self,
            LeaderboardEntry.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .onAppear {
                    let context = sharedModelContainer.mainContext
                    SeedData.seedExercises(context: context)
                    SeedData.seedSampleProfile(context: context)
                    SeedData.seedLeaderboard(context: context)
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
