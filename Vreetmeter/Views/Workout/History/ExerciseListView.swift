import SwiftUI
import SwiftData

struct ExerciseListView: View {
    @Query(sort: \Exercise.name) private var exercises: [Exercise]
    @State private var query = ""

    private var results: [Exercise] {
        if query.isEmpty { return exercises }
        return exercises.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        List {
            ForEach(results) { exercise in
                NavigationLink(value: exercise) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(exercise.name)
                        if let last = exercise.history.first, let session = last.session {
                            HStack {
                                Text(session.startedAt.formatted(date: .abbreviated, time: .omitted))
                                if let best = last.bestSet { Text("· \(best.summary)") }
                            }.font(.caption).foregroundStyle(.secondary)
                        } else {
                            Text("Not performed yet").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }.overlay {
            if exercises.isEmpty {
                ContentUnavailableView("No exercises yet", systemImage: "dumbbell", description: Text("Exercises from your programs and workouts show up here."))
            }
        }.searchable(text: $query)
            .navigationTitle("Exercises")
    }
}
