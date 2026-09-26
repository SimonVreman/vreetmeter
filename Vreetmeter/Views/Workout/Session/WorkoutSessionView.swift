import SwiftUI
import SwiftData

struct WorkoutSessionView: View {
    var session: WorkoutSession
    var onClose: () -> Void

    @Environment(\.modelContext) private var modelContext
    @Environment(HealthState.self) private var health
    @Environment(SettingsState.self) private var settings

    @State private var showExercisePicker = false
    @State private var showDiscardConfirmation = false

    private var saveToHealth: Bool {
        settings.getValue(VMSettings.saveWorkoutsToHealth.key) as? Bool ?? true
    }

    private func finish() {
        WorkoutPlanner.finish(session, in: modelContext)
        try? modelContext.save()

        if saveToHealth {
            Task {
                session.healthKitWorkoutID = try? await health.saveWorkout(session: session)
            }
        }
        onClose()
    }

    private func delete() {
        if let id = session.healthKitWorkoutID {
            Task { try? await health.deleteWorkout(id: id) }
        }
        modelContext.delete(session)
        try? modelContext.save()
        onClose()
    }

    private func removeEntry(_ entry: LoggedExercise) {
        session.entries.removeAll { $0.persistentModelID == entry.persistentModelID }
        modelContext.delete(entry)
    }

    var body: some View {
        List {
            Section {
                LabeledContent("Started", value: session.startedAt.formatted(date: .abbreviated, time: .shortened))
                if let endedAt = session.endedAt {
                    LabeledContent("Duration", value: Duration.seconds(endedAt.timeIntervalSince(session.startedAt))
                        .formatted(.units(allowed: [.hours, .minutes], width: .abbreviated)))
                    LabeledContent("Volume", value: "\(WorkoutMath.formatLoad(session.volume)) kg")
                }
                if let week = session.programDay?.week, let note = week.note {
                    Text(note).font(.callout).foregroundStyle(.orange)
                }
            }

            ForEach(session.sortedEntries) { entry in
                LoggedExerciseSection(entry: entry, session: session, onRemove: { removeEntry(entry) })
            }

            Section {
                Button("Add exercise", systemImage: "plus") { showExercisePicker = true }
            }
        }.navigationTitle(session.title)
            .navigationBarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                if !session.isFinished {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Finish", action: finish)
                    }
                }
                ToolbarItem(placement: .secondaryAction) {
                    Button(session.isFinished ? "Delete workout" : "Discard workout", systemImage: "trash", role: .destructive) {
                        showDiscardConfirmation = true
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
            .confirmationDialog(
                session.isFinished ? "Delete this workout?" : "Discard this workout?",
                isPresented: $showDiscardConfirmation,
                titleVisibility: .visible
            ) {
                Button(session.isFinished ? "Delete" : "Discard", role: .destructive, action: delete)
            } message: {
                Text("All logged sets of this workout will be removed.")
            }
            .sheet(isPresented: $showExercisePicker) {
                ExercisePickerSheet { exercise in
                    WorkoutPlanner.addExercise(exercise, to: session)
                }
            }
    }
}

private struct LoggedExerciseSection: View {
    var entry: LoggedExercise
    var session: WorkoutSession
    var onRemove: () -> Void

    @Environment(\.modelContext) private var modelContext

    private var previousSets: [LoggedSet] {
        WorkoutPlanner.previousSets(for: entry.exercise, before: session)
    }

    /// The planned exercise and its substitutions, to swap between.
    private var alternatives: [Exercise] {
        guard let planned = entry.planned else { return [] }
        return ([planned.exercise].compactMap { $0 } + planned.substitutions)
            .filter { $0.persistentModelID != entry.exercise?.persistentModelID }
    }

    private func removeSet(_ set: LoggedSet) {
        entry.sets.removeAll { $0.persistentModelID == set.persistentModelID }
        modelContext.delete(set)
    }

    var body: some View {
        let previous = previousSets

        Section {
            if let planned = entry.planned {
                PlannedTargetView(planned: planned)
            }

            ForEach(Array(entry.sortedSets.enumerated()), id: \.element.id) { index, set in
                LoggedSetRow(
                    index: index,
                    set: set,
                    previous: WorkoutPlanner.previousSet(at: index, in: previous)
                ).swipeActions {
                    Button("Delete", systemImage: "trash", role: .destructive) { removeSet(set) }
                }
            }

            Button("Add set", systemImage: "plus") { WorkoutPlanner.addSet(to: entry) }
                .font(.subheadline)
        } header: {
            HStack {
                if let group = entry.planned?.supersetGroup, !group.isEmpty {
                    Text(group)
                        .font(.caption2).fontWeight(.bold)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(.tint.opacity(0.2), in: .capsule)
                }
                Text(entry.exercise?.name ?? "Unknown exercise")
                Spacer()
                Menu {
                    if !alternatives.isEmpty {
                        Section("Swap for") {
                            ForEach(alternatives) { exercise in
                                Button(exercise.name) { WorkoutPlanner.swap(entry, to: exercise) }
                            }
                        }
                    }
                    Button("Remove exercise", systemImage: "trash", role: .destructive, action: onRemove)
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
}

private struct PlannedTargetView: View {
    var planned: PlannedExercise

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(planned.targetDescription).font(.subheadline).fontWeight(.medium)

            HStack(spacing: 12) {
                if !planned.warmupSets.isEmpty && planned.warmupSets != "0" {
                    Label("\(planned.warmupSets) warm-up", systemImage: "flame")
                }
                if let rest = planned.restDescription {
                    Label(rest, systemImage: "timer")
                }
            }.font(.caption).foregroundStyle(.secondary)

            if let technique = planned.intensityTechnique, !technique.isEmpty {
                Label(technique, systemImage: "bolt.fill")
                    .font(.caption).foregroundStyle(.orange)
            }

            if let notes = planned.notes, !notes.isEmpty {
                DisclosureGroup("Notes") {
                    Text(notes).font(.caption).foregroundStyle(.secondary)
                }.font(.caption)
            }
        }
    }
}

private struct LoggedSetRow: View {
    var index: Int
    var set: LoggedSet
    var previous: LoggedSet?

    @State private var loadText = ""
    @State private var repsText = ""

    private func syncFromModel() {
        if WorkoutMath.parseLoad(loadText) != set.load {
            loadText = set.load.map { WorkoutMath.formatLoad($0) } ?? ""
        }
        if Int(repsText) != set.reps {
            repsText = set.reps.map(String.init) ?? ""
        }
    }

    private func toggleCompleted() {
        if set.isCompleted {
            set.completedAt = nil
        } else {
            WorkoutPlanner.complete(set, previous: previous)
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Text("\(index + 1)")
                .font(.footnote).foregroundStyle(.secondary)
                .frame(width: 20)

            TextField("kg", text: $loadText, prompt: Text(previous?.load.map { WorkoutMath.formatLoad($0) } ?? "kg"))
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.trailing)
                .onChange(of: loadText) { set.load = WorkoutMath.parseLoad(loadText) }

            Text("kg ×").font(.footnote).foregroundStyle(.secondary)

            TextField("reps", text: $repsText, prompt: Text(previous?.reps.map(String.init) ?? "reps"))
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 64)
                .onChange(of: repsText) { set.reps = Int(repsText) }

            Button(action: toggleCompleted) {
                Image(systemName: set.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(set.isCompleted ? AnyShapeStyle(.green) : AnyShapeStyle(.secondary))
            }.buttonStyle(.plain)
                .accessibilityLabel(set.isCompleted ? "Mark set \(index + 1) as not done" : "Mark set \(index + 1) as done")
        }.onAppear(perform: syncFromModel)
            .onChange(of: set.load) { syncFromModel() }
            .onChange(of: set.reps) { syncFromModel() }
    }
}
