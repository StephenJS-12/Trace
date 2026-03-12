//
//  ExercisePoolView.swift
//  Trace
//
//  Browse and manage exercises in a category
//

import SwiftUI
import SwiftData

struct ExercisePoolView: View {
    let category: ExerciseCategory
    @Query private var allExercises: [Exercise]
    @State private var showAddExercise = false
    @State private var searchText = ""
    
    private var exercises: [Exercise] {
        let filtered = allExercises.filter { $0.category == category }
        if searchText.isEmpty { return filtered }
        return filtered.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        List {
            ForEach(exercises) { exercise in
                HStack(spacing: 14) {
                    Image(systemName: exercise.workoutType.icon)
                        .font(.body)
                        .foregroundColor(.traceAccent)
                        .frame(width: 36, height: 36)
                        .background(Color.traceAccentDim)
                        .cornerRadius(8)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(exercise.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.traceTextPrimary)
                        Text(exercise.workoutType.rawValue)
                            .font(.caption)
                            .foregroundColor(.traceTextSecondary)
                    }
                    
                    Spacer()
                    
                    if exercise.isCustom {
                        Text("Custom")
                            .font(.caption2)
                            .foregroundColor(.traceAccent)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.traceAccentDim)
                            .cornerRadius(6)
                    }
                }
                .listRowBackground(Color.traceCard)
            }
        }
        .searchable(text: $searchText, prompt: "Search exercises")
        .scrollContentBackground(.hidden)
        .background(Color.traceBackground)
        .navigationTitle(category.rawValue)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAddExercise = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.traceAccent)
                }
            }
        }
        .sheet(isPresented: $showAddExercise) {
            AddExerciseSheet(category: category)
        }
    }
}

// MARK: - Add Exercise Sheet
struct AddExerciseSheet: View {
    let category: ExerciseCategory
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var selectedType: WorkoutType = .strength
    @State private var instructions = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise Name") {
                    TextField("e.g. Cable Flyes", text: $name)
                }
                
                Section("Type") {
                    Picker("Workout Type", selection: $selectedType) {
                        ForEach(WorkoutType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Instructions (Optional)") {
                    TextField("How to perform this exercise", text: $instructions, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.traceBackground)
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let exercise = Exercise(
                            name: name,
                            category: category,
                            workoutType: selectedType,
                            instructions: instructions,
                            isCustom: true
                        )
                        context.insert(exercise)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}
