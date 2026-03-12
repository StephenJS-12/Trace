//
//  NewWorkoutSheet.swift
//  Trace
//
//  Quick sheet to choose workout type and start
//

import SwiftUI
import SwiftData

struct NewWorkoutSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Select the areas\nyou want to focus on")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.traceTextPrimary)
                        .padding(.top, 8)
                    
                    ForEach(ExerciseCategory.allCases) { category in
                        NavigationLink(destination: CategoryWorkoutSetupView(category: category)) {
                            HStack(spacing: 14) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(category.rawValue)
                                        .font(.headline)
                                        .foregroundColor(.traceTextPrimary)
                                    Text(categorySubtitle(category))
                                        .font(.caption)
                                        .foregroundColor(.traceTextSecondary)
                                }
                                Spacer()
                                Image(systemName: category.icon)
                                    .font(.title2)
                                    .foregroundColor(.traceAccent)
                            }
                            .padding()
                            .background(Color.traceCard)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.traceAccent.opacity(0.2), lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .background(Color.traceBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func categorySubtitle(_ category: ExerciseCategory) -> String {
        switch category {
        case .upperBody: return "Shoulders, Chest, Biceps"
        case .lowerBody: return "Glutes, Hamstrings, Quads"
        case .core: return "Abs, Obliques, Lower Back"
        case .back: return "Lats, Traps, Rhomboids"
        case .mobility: return "Flexibility, Stretching"
        case .cardio: return "Running, Cycling, Swimming"
        case .fullBody: return "Complete body workout"
        }
    }
}

// MARK: - Category Workout Setup
struct CategoryWorkoutSetupView: View {
    let category: ExerciseCategory
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationLink(destination: StartWorkoutView(workoutType: .strength)) {
            Text("Start Workout")
        }
        .buttonStyle(AccentButtonStyle())
        .padding()
        .background(Color.traceBackground)
        .navigationTitle(category.rawValue)
    }
}

// MARK: - Templates List
struct TemplatesListView: View {
    @Query(sort: \WorkoutTemplate.usageCount, order: .reverse) private var templates: [WorkoutTemplate]
    @Environment(\.modelContext) private var context
    
    var body: some View {
        List {
            if templates.isEmpty {
                Text("Templates are auto-created when you complete workouts.")
                    .foregroundColor(.traceTextSecondary)
                    .listRowBackground(Color.traceBackground)
            }
            
            ForEach(templates) { template in
                NavigationLink(destination: StartWorkoutFromTemplateView(template: template)) {
                    HStack(spacing: 14) {
                        Image(systemName: template.workoutType.icon)
                            .font(.title3)
                            .foregroundColor(.traceAccent)
                            .frame(width: 40, height: 40)
                            .background(Color.traceAccentDim)
                            .cornerRadius(10)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(template.name)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.traceTextPrimary)
                            Text("\(template.exerciseNames.count) exercises · \(template.targetCategory.rawValue)")
                                .font(.caption)
                                .foregroundColor(.traceTextSecondary)
                        }
                        
                        Spacer()
                        
                        Text("Used \(template.usageCount)x")
                            .font(.caption)
                            .foregroundColor(.traceTextTertiary)
                    }
                }
                .listRowBackground(Color.traceCard)
            }
            .onDelete { indexSet in
                for index in indexSet {
                    context.delete(templates[index])
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.traceBackground)
        .navigationTitle("Templates")
    }
}

// MARK: - Start from Template
struct StartWorkoutFromTemplateView: View {
    let template: WorkoutTemplate
    @Environment(\.modelContext) private var context
    
    var body: some View {
        StartWorkoutView(workoutType: template.workoutType)
            .onAppear {
                template.usageCount += 1
                template.lastUsedDate = Date()
            }
    }
}

// MARK: - Workout History
struct WorkoutHistoryView: View {
    @Query(sort: \Workout.date, order: .reverse) private var workouts: [Workout]
    
    var body: some View {
        List {
            ForEach(workouts) { workout in
                NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                    WorkoutHistoryRow(workout: workout)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.traceBackground)
        .navigationTitle("History")
    }
}

// MARK: - Workout Detail
struct WorkoutDetailView: View {
    let workout: Workout
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Stats
                HStack(spacing: 12) {
                    StatCard(icon: "clock.fill", value: "\(Int(workout.duration / 60))m", label: "Duration")
                    StatCard(icon: "star.fill", value: "\(workout.pointsEarned)", label: "Points")
                    StatCard(icon: "flame.fill", value: "\(Int(workout.caloriesBurned))", label: "Calories")
                }
                
                // Exercises
                Text("Exercises")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.traceTextPrimary)
                
                ForEach(workout.exercises) { log in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(log.exerciseName)
                            .font(.headline)
                            .foregroundColor(.traceTextPrimary)
                        
                        ForEach(log.sets.sorted { $0.setNumber < $1.setNumber }) { set in
                            HStack {
                                Text("Set \(set.setNumber)")
                                    .foregroundColor(.traceTextSecondary)
                                Spacer()
                                Text("\(set.weight, specifier: "%.1f") kg × \(set.reps)")
                                    .foregroundColor(.traceTextPrimary)
                                Image(systemName: set.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(set.isCompleted ? .traceAccent : .traceTextTertiary)
                            }
                            .font(.subheadline)
                        }
                    }
                    .cardStyle()
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .background(Color.traceBackground)
        .navigationTitle(workout.name)
    }
}
