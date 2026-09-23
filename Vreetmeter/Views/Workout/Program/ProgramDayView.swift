import SwiftUI
import SwiftData

struct ProgramDayView: View {
    @Bindable var day: ProgramDay
    var onStart: (ProgramDay) -> Void

    @Environment(\.modelContext) private var modelContext

    @State private var showExercisePicker = false
    @State private var editing: PlannedExercise?
    @State private var added: PlannedExercise?

    private var exercises: [PlannedExercise] { day.sortedExercises }

    private func add(_ exercise: Exercise) {
        let planned = PlannedExercise(sortOrder: (day.exercises.map(\.sortOrder).max() ?? -1) + 1)
        day.exercises.append(planned)
        planned.exercise = exercise
        added = planned
    }

    private func onDelete(at offsets: IndexSet) {
        let sorted = exercises
        for index in offsets {
            day.exercises.removeAll { $0.persistentModelID == sorted[index].persistentModelID }
            modelContext.delete(sorted[index])
        }
        ProgramEditing.renumber(day.sortedExercises) { $0.sortOrder = $1 }
    }

    var body: some View {
        List {
            Section {
                TextField("Name", text: $day.name)
                Picker("Type", selection: $day.kind) {
                    ForEach(ProgramDayKind.allCases, id: \.self) { Text($0.label).tag($0) }
                }
            }

            if day.kind == .training {
                Section("Exercises") {
                    ForEach(exercises) { planned in
                        Button { editing = planned } label: {
                            HStack {
                                if let group = planned.supersetGroup, !group.isEmpty {
                                    Text(group).font(.caption).fontWeight(.bold).foregroundStyle(.tint)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(planned.exercise?.name ?? "No exercise").foregroundStyle(Color.primary)
                                    Text(planned.targetDescription).font(.caption).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }.onDelete(perform: onDelete)
                        .onMove { ProgramEditing.move(exercises, fromOffsets: $0, toOffset: $1) { $0.sortOrder = $1 } }

                    Button("Add exercise", systemImage: "plus") { showExercisePicker = true }
                }

                Section {
                    Button("Start this workout", systemImage: "play.fill") { onStart(day) }
                        .disabled(day.exercises.isEmpty)
                }
            }
        }.navigationTitle(day.name)
            .toolbar { EditButton() }
            .sheet(isPresented: $showExercisePicker, onDismiss: {
                // Edit the targets of a newly added exercise once the picker is gone.
                editing = added
                added = nil
            }) {
                ExercisePickerSheet(onSelect: add)
            }
            .sheet(item: $editing) { planned in
                PlannedExerciseEditorSheet(planned: planned)
            }
    }
}
