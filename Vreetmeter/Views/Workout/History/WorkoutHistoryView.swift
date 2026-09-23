import SwiftUI
import SwiftData

private struct MonthGroup: Identifiable {
    let month: Date
    let sessions: [WorkoutSession]

    var id: Date { month }
}

struct WorkoutHistoryView: View {
    @Query(filter: #Predicate<WorkoutSession> { $0.endedAt != nil }, sort: \WorkoutSession.startedAt, order: .reverse)
    private var sessions: [WorkoutSession]

    private var sessionsByMonth: [MonthGroup] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: sessions) {
            calendar.date(from: calendar.dateComponents([.year, .month], from: $0.startedAt)) ?? $0.startedAt
        }
        return grouped.keys.sorted(by: >).map { MonthGroup(month: $0, sessions: grouped[$0] ?? []) }
    }

    var body: some View {
        List {
            ForEach(sessionsByMonth) { group in
                Section(group.month.formatted(.dateTime.month(.wide).year())) {
                    ForEach(group.sessions) { session in
                        NavigationLink(value: session) { WorkoutSessionRow(session: session) }
                    }
                }
            }
        }.overlay {
            if sessions.isEmpty {
                ContentUnavailableView("No workouts yet", systemImage: "clock", description: Text("Finished workouts show up here."))
            }
        }.navigationTitle("History")
    }
}
