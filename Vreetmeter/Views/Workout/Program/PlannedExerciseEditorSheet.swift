import SwiftUI
import SwiftData

struct PlannedExerciseEditorSheet: View {
    @Bindable var planned: PlannedExercise

    @Environment(\.dismiss) private var dismiss

    private enum PickerTarget: Identifiable {
        case exercise
        case substitution

        var id: Self { self }
    }

    @State private var pickerTarget: PickerTarget?
    @State private var restText = ""

    private func optionalText(_ keyPath: ReferenceWritableKeyPath<PlannedExercise, String?>) -> Binding<String> {
        Binding(
            get: { planned[keyPath: keyPath] ?? "" },
            set: { planned[keyPath: keyPath] = $0.isEmpty ? nil : $0 }
        )
    }

    private func onPick(_ exercise: Exercise) {
        switch pickerTarget {
        case .exercise:
            planned.exercise = exercise
        case .substitution:
            if !planned.substitutions.contains(where: { $0.persistentModelID == exercise.persistentModelID }) {
                planned.substitutions.append(exercise)
            }
        case nil:
            break
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise") {
                    Button(planned.exercise?.name ?? "Choose exercise") { pickerTarget = .exercise }
                    TextField("Superset group, e.g. A", text: optionalText(\.supersetGroup))
                }

                Section("Sets") {
                    Stepper("\(planned.workingSets) working sets", value: $planned.workingSets, in: 0...20)
                    LabeledContent("Warm-up sets") {
                        TextField("e.g. 1-2", text: $planned.warmupSets).multilineTextAlignment(.trailing)
                    }
                    LabeledContent("Reps") {
                        TextField("e.g. 8-10", text: $planned.repTarget).multilineTextAlignment(.trailing)
                    }
                    LabeledContent("Early set RPE") {
                        TextField("e.g. ~8-9", text: optionalText(\.earlyRPE)).multilineTextAlignment(.trailing)
                    }
                    LabeledContent("Last set RPE") {
                        TextField("e.g. 10", text: optionalText(\.lastRPE)).multilineTextAlignment(.trailing)
                    }
                    LabeledContent("Rest") {
                        TextField("e.g. 2-3 min", text: $restText)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: restText) {
                                let rest = WorkoutMath.parseRest(restText)
                                planned.restMinSeconds = rest?.min
                                planned.restMaxSeconds = rest?.max
                            }
                    }
                }

                Section("Intensity technique") {
                    TextField("e.g. Myo-reps on the last set", text: optionalText(\.intensityTechnique), axis: .vertical)
                }

                Section("Substitutions") {
                    ForEach(planned.substitutions) { exercise in
                        Text(exercise.name)
                    }.onDelete { offsets in
                        planned.substitutions.remove(atOffsets: offsets)
                    }
                    Button("Add substitution", systemImage: "plus") { pickerTarget = .substitution }
                }

                Section("Notes") {
                    TextField("Cues and instructions", text: optionalText(\.notes), axis: .vertical)
                        .lineLimit(3...)
                }
            }.navigationTitle(planned.exercise?.name ?? "Exercise")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { dismiss() }
                    }
                }
                .sheet(item: $pickerTarget) { _ in
                    ExercisePickerSheet(onSelect: onPick)
                }
                .onAppear { restText = planned.restDescription ?? "" }
        }
    }
}
