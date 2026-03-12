//
//  HomeView.swift
//  Trace
//
//  Dashboard: greeting, streak, quick stats, recent workouts
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \Workout.date, order: .reverse) private var workouts: [Workout]
    @Query private var profiles: [UserProfile]
    
    private var profile: UserProfile? { profiles.first }
    
    private var thisWeekWorkouts: [Workout] {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        return workouts.filter { $0.date >= startOfWeek && $0.isCompleted }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Greeting
                    greetingSection
                    
                    // Streak Card
                    streakCard
                    
                    // Weekly Stats Row
                    weeklyStatsRow
                    
                    // Quick Start
                    quickStartSection
                    
                    // Recent Workouts
                    recentWorkoutsSection
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .background(Color.traceBackground)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Greeting
    private var greetingSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(greetingText)
                .font(.subheadline)
                .foregroundColor(.traceTextSecondary)
            Text(profile?.displayName ?? "Athlete")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.traceTextPrimary)
        }
        .padding(.top, 8)
    }
    
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good Morning" }
        if hour < 17 { return "Good Afternoon" }
        return "Good Evening"
    }
    
    // MARK: - Streak
    private var streakCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.traceAccent)
                        .font(.title2)
                    Text("\(profile?.currentStreak ?? 0)")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.traceTextPrimary)
                }
                Text("Week Streak")
                    .font(.subheadline)
                    .foregroundColor(.traceTextSecondary)
            }
            
            Spacer()
            
            // Weekly progress ring
            ZStack {
                Circle()
                    .stroke(Color.traceCardLight, lineWidth: 8)
                    .frame(width: 70, height: 70)
                Circle()
                    .trim(from: 0, to: weeklyProgress)
                    .stroke(Color.traceAccent, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 70, height: 70)
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 0) {
                    Text("\(thisWeekWorkouts.count)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.traceTextPrimary)
                    Text("/\(profile?.streakGoal ?? 4)")
                        .font(.caption2)
                        .foregroundColor(.traceTextSecondary)
                }
            }
        }
        .cardStyle()
    }
    
    private var weeklyProgress: CGFloat {
        let goal = max(profile?.streakGoal ?? 4, 1)
        return min(CGFloat(thisWeekWorkouts.count) / CGFloat(goal), 1.0)
    }
    
    // MARK: - Weekly Stats
    private var weeklyStatsRow: some View {
        HStack(spacing: 12) {
            StatCard(
                icon: "figure.run",
                value: "\(thisWeekWorkouts.count)",
                label: "Workouts"
            )
            StatCard(
                icon: "clock.fill",
                value: formattedDuration,
                label: "Total Time"
            )
            StatCard(
                icon: "star.fill",
                value: "\(profile?.totalPoints ?? 0)",
                label: "Points"
            )
        }
    }
    
    private var formattedDuration: String {
        let totalMinutes = Int(thisWeekWorkouts.reduce(0) { $0 + $1.duration } / 60)
        if totalMinutes >= 60 {
            return "\(totalMinutes / 60)h \(totalMinutes % 60)m"
        }
        return "\(totalMinutes)m"
    }
    
    // MARK: - Quick Start
    private var quickStartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Start")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.traceTextPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(WorkoutType.allCases) { type in
                        NavigationLink(destination: StartWorkoutView(workoutType: type)) {
                            QuickStartCard(type: type)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Recent Workouts
    private var recentWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.traceTextPrimary)
                Spacer()
            }
            
            if workouts.isEmpty {
                Text("No workouts yet. Start one!")
                    .font(.subheadline)
                    .foregroundColor(.traceTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 30)
            } else {
                ForEach(workouts.prefix(5)) { workout in
                    WorkoutHistoryRow(workout: workout)
                }
            }
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.traceAccent)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.traceTextPrimary)
            Text(label)
                .font(.caption)
                .foregroundColor(.traceTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.traceCard)
        .cornerRadius(14)
    }
}

// MARK: - Quick Start Card
struct QuickStartCard: View {
    let type: WorkoutType
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: type.icon)
                .font(.title2)
                .foregroundColor(.black)
                .frame(width: 48, height: 48)
                .background(Color.traceAccent)
                .cornerRadius(12)
            Text(type.rawValue)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.traceTextPrimary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
    }
}

// MARK: - Workout History Row
struct WorkoutHistoryRow: View {
    let workout: Workout
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: workout.workoutType.icon)
                .font(.title3)
                .foregroundColor(.traceAccent)
                .frame(width: 44, height: 44)
                .background(Color.traceAccentDim)
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.traceTextPrimary)
                Text(workout.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.traceTextSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(workout.duration / 60))m")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.traceTextPrimary)
                Text("+\(workout.pointsEarned) pts")
                    .font(.caption)
                    .foregroundColor(.traceAccent)
            }
        }
        .padding()
        .background(Color.traceCard)
        .cornerRadius(14)
    }
}
