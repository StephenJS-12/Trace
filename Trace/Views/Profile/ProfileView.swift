//
//  ProfileView.swift
//  Trace
//
//  User profile with stats, streak, and customization
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Query private var profiles: [UserProfile]
    @Query(sort: \Workout.date, order: .reverse) private var workouts: [Workout]
    @State private var showEditProfile = false
    
    private var profile: UserProfile? { profiles.first }
    
    // Monthly workout data for chart
    private var weeklyData: [(String, Int)] {
        let calendar = Calendar.current
        let today = Date()
        return (0..<7).reversed().map { weeksAgo in
            let weekStart = calendar.date(byAdding: .weekOfYear, value: -weeksAgo, to: today)!
            let weekEnd = calendar.date(byAdding: .weekOfYear, value: -weeksAgo + 1, to: today)!
            let count = workouts.filter { $0.date >= weekStart && $0.date < weekEnd && $0.isCompleted }.count
            let label = weekStart.formatted(.dateTime.month(.abbreviated).day())
            return (label, count)
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    profileHeader
                    
                    // Stats Grid
                    statsGrid
                    
                    // Streak Section
                    streakSection
                    
                    // Weekly Activity Chart
                    activityChart
                    
                    // Settings
                    settingsSection
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .background(Color.traceBackground)
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showEditProfile = true
                    } label: {
                        Image(systemName: "pencil.circle")
                            .foregroundColor(.traceAccent)
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileSheet()
            }
        }
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: 12) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.traceAccent)
                    .frame(width: 80, height: 80)
                Text(String((profile?.displayName ?? "A").prefix(1)).uppercased())
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
            }
            
            Text(profile?.displayName ?? "Athlete")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.traceTextPrimary)
            
            Text("@\(profile?.username ?? "athlete")")
                .font(.subheadline)
                .foregroundColor(.traceTextSecondary)
            
            if let bio = profile?.bio, !bio.isEmpty {
                Text(bio)
                    .font(.subheadline)
                    .foregroundColor(.traceTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            Text("Joined \(profile?.joinDate.formatted(date: .abbreviated, time: .omitted) ?? "")")
                .font(.caption)
                .foregroundColor(.traceTextTertiary)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Stats Grid
    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            profileStatCard(icon: "figure.run", value: "\(profile?.totalWorkouts ?? 0)", label: "Workouts")
            profileStatCard(icon: "star.fill", value: "\(profile?.totalPoints ?? 0)", label: "Total Points")
            profileStatCard(icon: "flame.fill", value: "\(profile?.currentStreak ?? 0)", label: "Current Streak")
            profileStatCard(icon: "trophy.fill", value: "\(profile?.longestStreak ?? 0)", label: "Best Streak")
        }
    }
    
    private func profileStatCard(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.traceAccent)
            Text(value)
                .font(.title2)
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
    
    // MARK: - Streak
    private var streakSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Streak Goal")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.traceTextPrimary)
            
            HStack {
                Text("\(profile?.streakGoal ?? 4) workouts per week")
                    .font(.subheadline)
                    .foregroundColor(.traceTextSecondary)
                Spacer()
                // Days of week dots
                HStack(spacing: 6) {
                    ForEach(["M","T","W","T","F","S","S"], id: \.self) { day in
                        VStack(spacing: 4) {
                            Circle()
                                .fill(Color.traceAccent.opacity(0.3))
                                .frame(width: 24, height: 24)
                            Text(day)
                                .font(.system(size: 9))
                                .foregroundColor(.traceTextTertiary)
                        }
                    }
                }
            }
        }
        .cardStyle()
    }
    
    // MARK: - Activity Chart (simple bar chart)
    private var activityChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Activity")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.traceTextPrimary)
            
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(weeklyData, id: \.0) { label, count in
                    VStack(spacing: 4) {
                        Text("\(count)")
                            .font(.caption2)
                            .foregroundColor(.traceTextSecondary)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(count > 0 ? Color.traceAccent : Color.traceCardLight)
                            .frame(height: max(CGFloat(count) * 20, 4))
                        Text(label)
                            .font(.system(size: 8))
                            .foregroundColor(.traceTextTertiary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 100)
        }
        .cardStyle()
    }
    
    // MARK: - Settings
    private var settingsSection: some View {
        VStack(spacing: 2) {
            settingsRow(icon: "bell.fill", title: "Notifications")
            settingsRow(icon: "heart.fill", title: "Health Data")
            settingsRow(icon: "applewatch", title: "Apple Watch")
            settingsRow(icon: "gearshape.fill", title: "Preferences")
            settingsRow(icon: "questionmark.circle.fill", title: "Help & Support")
        }
    }
    
    private func settingsRow(icon: String, title: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundColor(.traceAccent)
                .frame(width: 28)
            Text(title)
                .font(.subheadline)
                .foregroundColor(.traceTextPrimary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.traceTextTertiary)
        }
        .padding()
        .background(Color.traceCard)
        .cornerRadius(14)
    }
}

// MARK: - Edit Profile Sheet
struct EditProfileSheet: View {
    @Query private var profiles: [UserProfile]
    @Environment(\.dismiss) private var dismiss
    @State private var displayName = ""
    @State private var username = ""
    @State private var bio = ""
    @State private var streakGoal = 4
    
    private var profile: UserProfile? { profiles.first }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Display Info") {
                    TextField("Display Name", text: $displayName)
                    TextField("Username", text: $username)
                    TextField("Bio", text: $bio, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                Section("Weekly Goal") {
                    Stepper("\(streakGoal) workouts per week", value: $streakGoal, in: 1...7)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.traceBackground)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                displayName = profile?.displayName ?? ""
                username = profile?.username ?? ""
                bio = profile?.bio ?? ""
                streakGoal = profile?.streakGoal ?? 4
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        profile?.displayName = displayName
                        profile?.username = username
                        profile?.bio = bio
                        profile?.streakGoal = streakGoal
                        dismiss()
                    }
                }
            }
        }
    }
}
