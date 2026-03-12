//
//  WatchMainView.swift
//  TraceWatchApp Watch App
//
//  Main navigation for the watch - start workout, view stats
//

import SwiftUI

struct WatchMainView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    // Quick Start Button
                    NavigationLink(destination: WatchWorkoutView(workoutType: "Strength")) {
                        WatchQuickStartRow(icon: "dumbbell.fill", title: "Strength", color: .green)
                    }
                    
                    NavigationLink(destination: WatchWorkoutView(workoutType: "Cardio")) {
                        WatchQuickStartRow(icon: "figure.run", title: "Cardio", color: .orange)
                    }
                    
                    NavigationLink(destination: WatchWorkoutView(workoutType: "HIIT")) {
                        WatchQuickStartRow(icon: "bolt.fill", title: "HIIT", color: .red)
                    }
                    
                    NavigationLink(destination: WatchWorkoutView(workoutType: "Yoga")) {
                        WatchQuickStartRow(icon: "figure.yoga", title: "Yoga", color: .purple)
                    }
                    
                    Divider()
                        .padding(.vertical, 4)
                    
                    // Stats Summary
                    NavigationLink(destination: WatchStatsView()) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(.green)
                            Text("Stats")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(white: 0.15))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 4)
            }
            .navigationTitle("Trace")
        }
    }
}

// MARK: - Quick Start Row
struct WatchQuickStartRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 32)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
            
            Image(systemName: "play.circle.fill")
                .font(.title3)
                .foregroundColor(color)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(Color(white: 0.15))
        .cornerRadius(12)
    }
}

// MARK: - Watch Workout View (Active Session)
struct WatchWorkoutView: View {
    let workoutType: String
    @State private var isActive = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var heartRate: Int = 0
    @State private var calories: Int = 0
    @State private var timer: Timer?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 8) {
            if isActive {
                // Active workout display
                VStack(spacing: 4) {
                    // Timer
                    Text(formatTime(elapsedTime))
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundColor(.green)
                    
                    Text(workoutType)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                // Heart Rate
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                    Text("\(heartRate)")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("BPM")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                // Calories
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("\(calories)")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("cal")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                // End Button
                Button {
                    endWorkout()
                } label: {
                    Text("End")
                        .font(.headline)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.bordered)
                .tint(.red)
                
            } else {
                // Start screen
                VStack(spacing: 16) {
                    Image(systemName: workoutIcon)
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                    
                    Text(workoutType)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Button {
                        startWorkout()
                    } label: {
                        Text("Start")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
            }
        }
        .padding(.horizontal, 4)
        .navigationBarBackButtonHidden(isActive)
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private var workoutIcon: String {
        switch workoutType {
        case "Strength": return "dumbbell.fill"
        case "Cardio": return "figure.run"
        case "HIIT": return "bolt.fill"
        case "Yoga": return "figure.yoga"
        default: return "figure.walk"
        }
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let m = Int(seconds) / 60
        let s = Int(seconds) % 60
        return String(format: "%02d:%02d", m, s)
    }
    
    private func startWorkout() {
        isActive = true
        heartRate = Int.random(in: 70...85) // Simulated initial HR
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedTime += 1
            // Simulate heart rate and calorie changes
            if Int(elapsedTime) % 5 == 0 {
                heartRate = Int.random(in: 100...170)
                calories = Int(elapsedTime * 0.15)
            }
        }
    }
    
    private func endWorkout() {
        timer?.invalidate()
        isActive = false
        dismiss()
    }
}

// MARK: - Watch Stats View
struct WatchStatsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Streak
                WatchStatRow(icon: "flame.fill", color: .orange, label: "Streak", value: "0 weeks")
                WatchStatRow(icon: "figure.run", color: .green, label: "This Week", value: "0 workouts")
                WatchStatRow(icon: "star.fill", color: .yellow, label: "Points", value: "0 pts")
                WatchStatRow(icon: "clock.fill", color: .blue, label: "Total Time", value: "0m")
            }
            .padding(.horizontal, 4)
        }
        .navigationTitle("Stats")
    }
}

struct WatchStatRow: View {
    let icon: String
    let color: Color
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(white: 0.15))
        .cornerRadius(10)
    }
}
