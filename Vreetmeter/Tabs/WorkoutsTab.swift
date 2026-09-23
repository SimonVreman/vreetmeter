import SwiftUI
import SwiftData

enum WorkoutsDestination: Hashable {
    case programs
    case history
    case exercises
}

struct WorkoutsTab: View {
    @Environment(\.modelContext) private var modelContext

    @State private var path = NavigationPath()

    @Query(filter: #Predicate<WorkoutProgram> { $0.isActive }) private var activePrograms: [WorkoutProgram]
    @Query(filter: #Predicate<WorkoutSession> { $0.endedAt == nil }, sort: \WorkoutSession.startedAt, order: .reverse)
    private var unfinishedSessions: [WorkoutSession]
    @Query(filter: #Predicate<WorkoutSession> { $0.endedAt != nil }, sort: \WorkoutSession.startedAt, order: .reverse)
    private var finishedSessions: [WorkoutSession]

    private var activeProgram: WorkoutProgram? { activePrograms.first }

    private func start(_ day: ProgramDay) {
        let session = WorkoutPlanner.startSession(for: day, in: modelContext)
        path.append(session)
    }

    private func startEmpty() {
        let session = WorkoutPlanner.startEmptySession(in: modelContext)
        path.append(session)
    }

    var body: some View {
        NavigationStack(path: $path) {
            List {
                currentSection

                if !finishedSessions.isEmpty {
                    Section("Recent") {
                        ForEach(finishedSessions.prefix(5)) { session in
                            NavigationLink(value: session) { WorkoutSessionRow(session: session) }
                        }
                        NavigationLink("All workouts", value: WorkoutsDestination.history)
                    }
                }

                Section {
                    NavigationLink(value: WorkoutsDestination.programs) {
                        Label("Programs", systemImage: "list.bullet.rectangle")
                    }
                    NavigationLink(value: WorkoutsDestination.exercises) {
                        Label("Exercises", systemImage: "chart.line.uptrend.xyaxis")
                    }
                }
            }.navigationTitle("Workouts")
                .navigationDestination(for: WorkoutsDestination.self) { destination in
                    switch destination {
                    case .programs: ProgramListView()
                    case .history: WorkoutHistoryView()
                    case .exercises: ExerciseListView()
                    }
                }
                .navigationDestination(for: WorkoutSession.self) { session in
                    WorkoutSessionView(session: session) {
                        if !path.isEmpty { path.removeLast() }
                    }
                }
                .navigationDestination(for: WorkoutProgram.self) { ProgramView(program: $0) }
                .navigationDestination(for: ProgramWeek.self) { ProgramWeekView(week: $0) }
                .navigationDestination(for: ProgramDay.self) { ProgramDayView(day: $0, onStart: start) }
                .navigationDestination(for: Exercise.self) { ExerciseProgressView(exercise: $0) }
        }
    }

    @ViewBuilder
    private var currentSection: some View {
        if let session = unfinishedSessions.first {
            Section("In progress") {
                NavigationLink(value: session) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(session.title).font(.headline)
                        Text("Started \(session.startedAt.formatted(.relative(presentation: .named)))")
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                }
            }
        } else if let program = activeProgram {
            Section(program.name) {
                if let day = WorkoutPlanner.nextDay(in: program) {
                    VStack(alignment: .leading, spacing: 8) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Up next").font(.caption).foregroundStyle(.secondary)
                            Text(day.name).font(.title3).fontWeight(.semibold)
                            if let week = day.week {
                                Text([week.name, week.note].compactMap { $0 }.joined(separator: " · "))
                                    .font(.subheadline).foregroundStyle(.secondary)
                            }
                        }
                        Button {
                            start(day)
                        } label: {
                            Label("Start workout", systemImage: "play.fill").frame(maxWidth: .infinity)
                        }.buttonStyle(.borderedProminent)
                    }.padding(.vertical, 4)

                    NavigationLink("Preview \(day.name)", value: day)
                } else if program.trainingDays.isEmpty {
                    NavigationLink("This program has no workouts yet", value: program)
                } else {
                    Text("Program complete 🎉")
                    Button("Start over") { WorkoutPlanner.restart(program) }
                }

                Button("Start empty workout", action: startEmpty)
            }
        } else {
            Section {
                ContentUnavailableView {
                    Label("No active program", systemImage: "dumbbell")
                } description: {
                    Text("Create or import a program, or just start an empty workout.")
                } actions: {
                    NavigationLink("Programs", value: WorkoutsDestination.programs)
                        .buttonStyle(.borderedProminent)
                    Button("Start empty workout", action: startEmpty)
                }
            }
        }
    }
}

struct WorkoutSessionRow: View {
    var session: WorkoutSession

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(session.title).font(.headline)
            HStack {
                Text(session.startedAt.formatted(date: .abbreviated, time: .omitted))
                if let week = session.weekName { Text("· \(week)") }
                Spacer()
                Text("\(session.completedSetCount) sets")
            }.font(.subheadline).foregroundStyle(.secondary)
        }
    }
}
