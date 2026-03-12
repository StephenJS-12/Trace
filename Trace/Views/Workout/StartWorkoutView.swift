//
//  StartWorkoutView.swift
//  Trace
//
//  Active workout session - log sets, weights, reps in real time
//

import SwiftUI
import SwiftData

struct StartWorkoutView: View {
    let workoutType: WorkoutType
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var allExercises: [Exercise]
    @Query private var profiles: [UserProfile]
    
    @State private var workout: Workout?
    @State private var exerciseLogs: [ExerciseLog] = []
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var isActive = false
    @State private var showAddExercise = false
    @State private var showFinishConfirm = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Timer Bar
                timerBar
                
                // Exercise List
                ForEach(Array(exerciseLogs.enumerated()), id: \.element.id) { index, log in
                    ExerciseLogCard(
                        exerciseLog: log,
                        exerciseNumber: index + 1,
                        onRemove: { removeExercise(at: index) }
                    )
                }
                
                // Add Exercise Button
                Button {
                    showAddExercise = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Exercise")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                }
                .buttonStyle(SecondaryButtonStyle())
                .padding(.top, 8)
                
                // Finish Button
                Button("Finish Workout") {
                    showFinishConfirm = true
                }
                .buttonStyle(AccentButtonStyle())
                .padding(.top, 12)
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .background(Color.traceBackground)
        .navigationTitle(workoutType.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { startWorkout() }
        .onDisappear { timer?.invalidate() }
        .sheet(isPresented: $showAddExercise) {
            SelectExerciseSheet(workoutType: workoutType) { exercise in
                addExercise(exercise)
            }
        }
        .alert("Finish Workout?", isPresented: $showFinishConfirm) {
            Button("Finish", role: .destructive) { finishWorkout() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will save your workout and calculate points.")
        }
    }
    
    // MARK: - Timer
    private var timerBar: some View {
        HStack {
            Image(systemName: "timer")
                .foregroundColor(.traceAccent)
            Text(formatTime(elapsedTime))
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundColor(.traceTextPrimary)
            Spacer()
            Text("\(exerciseLogs.count) exercises")
                .font(.subheadline)
                .foregroundColor(.traceTextSecondary)
        }
        .cardStyle()
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let h = Int(seconds) / 3600
        let m = (Int(seconds) % 3600) / 60
        let s = Int(seconds) % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%02d:%02d", m, s)
    }
    
    // MARK: - Actions
    private func startWorkout() {
        let newWorkout = Workout(name: "\(workoutType.rawValue) Workout", workoutType: workoutType)
        context.insert(newWorkout)
        workout = newWorkout
        
        // Auto-add some exercises based on type
        let typeExercises = allExercises.filter { $0.workoutType == workoutType }
        let selected = Array(typeExercises.shuffled().prefix(4))
        for exercise in selected {
            addExercise(exercise)
        }
        
        // Start timer
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedTime += 1
        }
        isActive = true
    }
    
    private func addExercise(_ exercise: Exercise) {
        let log = ExerciseLog(exerciseName: exercise.name, category: exercise.category)
        // Add 3 default sets
        for i in 1...3 {
            let set = ExerciseSet(setNumber: i)
            
            // Progressive overload: suggest based on last performance
            if let last = WorkoutService.getLastPerformance(exerciseName: exercise.name, context: context) {
                let suggestion = WorkoutService.suggestProgression(lastWeight: last.weight, lastReps: last.reps)
                set.weight = suggestion.weight
                set.reps = suggestion.reps
            }
            
            log.sets.append(set)
        }
        log.workout = workout
        context.insert(log)
        exerciseLogs.append(log)
    }
    
    private func removeExercise(at index: Int) {
        let log = exerciseLogs.remove(at: index)
        context.delete(log)
    }
    
    private func finishWorkout() {
        timer?.invalidate()
        guard let workout = workout else { return }
        
        workout.duration = elapsedTime
        workout.isCompleted = true
        workout.exercises = exerciseLogs
        workout.pointsEarned = WorkoutService.calculatePoints(for: workout)
        
        // Update profile
        if let profile = profiles.first {
            profile.totalPoints += workout.pointsEarned
            profile.totalWorkouts += 1
            profile.lastWorkoutDate = Date()
        }
        
        // Save template from this workout
        saveAsTemplate(workout)
        
        try? context.save()
        dismiss()
    }
    
    private func saveAsTemplate(_ workout: Workout) {
        let names = exerciseLogs.map { $0.exerciseName }
        guard !names.isEmpty else { return }
        
        let category = exerciseLogs.first?.category ?? .fullBody
        let template = WorkoutTemplate(
            name: workout.name,
            workoutType: workout.workoutType,
            targetCategory: category,
            exerciseNames: names
        )
        context.insert(template)
    }
}

// MARK: - Exercise Log Card
struct ExerciseLogCard: View {
    @Bindable var exerciseLog: ExerciseLog
    let exerciseNumber: Int
    let onRemove: () -> Void
    @State private var showAddSet = false
    @Environment(\.modelContext) private var context
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("\(exerciseNumber). \(exerciseLog.exerciseName)")
                    .font(.headline)
                    .foregroundColor(.traceTextPrimary)
                Spacer()
                Button(role: .destructive) {
                    onRemove()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.traceTextTertiary)
                }
            }
            
            // Column Headers
            HStack {
                Text("SET")
                    .frame(width: 36)
                Text("KG")
                    .frame(maxWidth: .infinity)
                Text("REPS")
                    .frame(maxWidth: .infinity)
                Text("")
                    .frame(width: 44)
            }
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.traceTextTertiary)
            
            // Sets
            let sortedSets = exerciseLog.sets.sorted { $0.setNumber < $1.setNumber }
            ForEach(sortedSets) { exerciseSet in
                SetRow(exerciseSet: exerciseSet)
            }
            
            // Add Set
            Button {
                let newSet = ExerciseSet(setNumber: exerciseLog.sets.count + 1)
                exerciseLog.sets.append(newSet)
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Set")
                }
                .font(.caption)
                .foregroundColor(.traceAccent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
        }
        .cardStyle()
    }
}

// MARK: - Set Row
struct SetRow: View {
    @Bindable var exerciseSet: ExerciseSet
    
    var body: some View {
        HStack {
            Text("\(exerciseSet.setNumber)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.traceTextSecondary)
                .frame(width: 36)
            
            TextField("0", value: $exerciseSet.weight, format: .number)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: .infinity)
            
            TextField("0", value: $exerciseSet.reps, format: .number)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: .infinity)
            
            Button {
                exerciseSet.isCompleted.toggle()
            } label: {
                Image(systemName: exerciseSet.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(exerciseSet.isCompleted ? .traceAccent : .traceTextTertiary)
            }
            .frame(width: 44)
        }
    }
}

// MARK: - Select Exercise Sheet
struct SelectExerciseSheet: View {
    let workoutType: WorkoutType
    let onSelect: (Exercise) -> Void
    @Query private var exercises: [Exercise]
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    private var filtered: [Exercise] {
        let all = exercises
        if searchText.isEmpty { return all }
        return all.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(ExerciseCategory.allCases) { category in
                    let categoryExercises = filtered.filter { $0.category == category }
                    if !categoryExercises.isEmpty {
                        Section(category.rawValue) {
                            ForEach(categoryExercises) { exercise in
                                Button {
                                    onSelect(exercise)
                                    dismiss()
                                } label: {
                                    HStack {
                                        Text(exercise.name)
                                            .foregroundColor(.traceTextPrimary)
                                        Spacer()
                                        Image(systemName: "plus.circle")
                                            .foregroundColor(.traceAccent)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search exercises")
            .scrollContentBackground(.hidden)
            .background(Color.traceBackground)
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
