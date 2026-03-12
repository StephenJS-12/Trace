//
//  WorkoutsView.swift
//  Trace
//
//  Browse exercise categories, templates, and workout history
//

import SwiftUI
import SwiftData

struct WorkoutsView: View {
    @Query(sort: \Workout.date, order: .reverse) private var workouts: [Workout]
    @Query private var templates: [WorkoutTemplate]
    @State private var showNewWorkout = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Categories Grid
                    categoriesSection
                    
                    // Templates
                    templatesSection
                    
                    // History
                    historySection
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .background(Color.traceBackground)
            .navigationTitle("Workouts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showNewWorkout = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.traceAccent)
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showNewWorkout) {
                NewWorkoutSheet()
            }
        }
    }
    
    // MARK: - Categories
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Categories")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.traceTextPrimary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(ExerciseCategory.allCases) { category in
                    NavigationLink(destination: ExercisePoolView(category: category)) {
                        CategoryCard(category: category)
                    }
                }
            }
        }
    }
    
    // MARK: - Templates
    private var templatesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Templates")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.traceTextPrimary)
                Spacer()
                NavigationLink("View All") {
                    TemplatesListView()
                }
                .font(.subheadline)
                .foregroundColor(.traceAccent)
            }
            
            if templates.isEmpty {
                Text("Complete workouts to generate templates")
                    .font(.subheadline)
                    .foregroundColor(.traceTextSecondary)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(templates.prefix(5)) { template in
                            NavigationLink(destination: StartWorkoutFromTemplateView(template: template)) {
                                TemplateCard(template: template)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - History
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("History")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.traceTextPrimary)
                Spacer()
                NavigationLink("View All") {
                    WorkoutHistoryView()
                }
                .font(.subheadline)
                .foregroundColor(.traceAccent)
            }
            
            ForEach(workouts.prefix(3)) { workout in
                WorkoutHistoryRow(workout: workout)
            }
        }
    }
}

// MARK: - Category Card
struct CategoryCard: View {
    let category: ExerciseCategory
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.traceTextPrimary)
            }
            Spacer()
            Image(systemName: category.icon)
                .font(.title2)
                .foregroundColor(.traceAccent)
        }
        .padding()
        .background(Color.traceCard)
        .cornerRadius(14)
    }
}

// MARK: - Template Card
struct TemplateCard: View {
    let template: WorkoutTemplate
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: template.workoutType.icon)
                .font(.title3)
                .foregroundColor(.black)
                .frame(width: 40, height: 40)
                .background(Color.traceAccent)
                .cornerRadius(10)
            
            Text(template.name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.traceTextPrimary)
                .lineLimit(1)
            
            Text("\(template.exerciseNames.count) exercises")
                .font(.caption)
                .foregroundColor(.traceTextSecondary)
        }
        .padding()
        .frame(width: 140)
        .background(Color.traceCard)
        .cornerRadius(14)
    }
}
