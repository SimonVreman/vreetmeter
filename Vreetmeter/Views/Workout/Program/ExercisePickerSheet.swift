import SwiftUI
import SwiftData

struct ExercisePickerSheet: View {
    var onSelect: (Exercise) -> Void

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Exercise.name) private var exercises: [Exercise]
    @State private var query = ""

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var results: [Exercise] {
        if trimmedQuery.isEmpty { return exercises }
        return exercises.filter { $0.name.localizedCaseInsensitiveContains(trimmedQuery) }
    }

    private var hasExactMatch: Bool {
        exercises.contains { Exercise.normalizedName($0.name) == Exercise.normalizedName(trimmedQuery) }
    }

    private func select(_ exercise: Exercise) {
        onSelect(exercise)
        dismiss()
    }

    private func create() {
        let exercise = Exercise(name: trimmedQuery)
        modelContext.insert(exercise)
        select(exercise)
    }

    var body: some View {
        NavigationStack {
            List {
                if !trimmedQuery.isEmpty && !hasExactMatch {
                    Button("Create \"\(trimmedQuery)\"", systemImage: "plus", action: create)
                }

                ForEach(results) { exercise in
                    Button(exercise.name) { select(exercise) }
                        .foregroundStyle(.primary)
                }
            }.overlay {
                if exercises.isEmpty && trimmedQuery.isEmpty {
                    ContentUnavailableView("No exercises yet", systemImage: "dumbbell", description: Text("Search for an exercise name to create it."))
                }
            }.searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search or create")
                .navigationTitle("Exercise")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
        }
    }
}
