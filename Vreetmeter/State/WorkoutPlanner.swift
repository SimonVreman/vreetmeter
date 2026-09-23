import Foundation
import SwiftData

/// Program progression and session bookkeeping, kept free of views so it can be tested.
enum WorkoutPlanner {
    /// The training day to perform next: the one after the most recently finished day of the program,
    /// the first day if none was finished yet, or nil when the program is complete.
    static func nextDay(in program: WorkoutProgram) -> ProgramDay? {
        let days = program.trainingDays
        guard let latest = latestFinishedSession(in: program),
              let day = latest.programDay,
              let index = days.firstIndex(where: { $0.persistentModelID == day.persistentModelID })
        else { return days.first }

        return index + 1 < days.count ? days[index + 1] : nil
    }

    static func latestFinishedSession(in program: WorkoutProgram) -> WorkoutSession? {
        let since = program.startedAt ?? .distantPast
        return program.trainingDays
            .flatMap { $0.sessions }
            .filter { $0.isFinished && $0.startedAt >= since }
            .max { $0.startedAt < $1.startedAt }
    }

    /// Makes this the only active program, and starts it from the first day when it was not started before.
    static func activate(_ program: WorkoutProgram, in context: ModelContext) throws {
        for other in try context.fetch(FetchDescriptor<WorkoutProgram>()) where other.isActive {
            other.isActive = false
        }
        program.isActive = true
        if program.startedAt == nil { program.startedAt = .now }
    }

    /// Starts the program over from its first day, keeping the history of earlier runs.
    static func restart(_ program: WorkoutProgram) {
        program.startedAt = .now
    }

    static func startSession(for day: ProgramDay, in context: ModelContext, at date: Date = .now) -> WorkoutSession {
        let session = WorkoutSession(title: day.name, weekName: day.week?.name, startedAt: date)
        context.insert(session)
        session.programDay = day

        for planned in day.sortedExercises {
            let entry = LoggedExercise(sortOrder: session.entries.count)
            session.entries.append(entry)
            entry.exercise = planned.exercise
            entry.planned = planned
            for index in 0..<planned.workingSets {
                entry.sets.append(LoggedSet(sortOrder: index))
            }
        }

        return session
    }

    static func startEmptySession(in context: ModelContext, at date: Date = .now) -> WorkoutSession {
        let session = WorkoutSession(title: "Workout", startedAt: date)
        context.insert(session)
        return session
    }

    @discardableResult
    static func addExercise(_ exercise: Exercise, to session: WorkoutSession) -> LoggedExercise {
        let entry = LoggedExercise(sortOrder: (session.entries.map(\.sortOrder).max() ?? -1) + 1)
        session.entries.append(entry)
        entry.exercise = exercise
        let setCount = max(previousSets(for: exercise, before: session).count, 1)
        for index in 0..<setCount {
            entry.sets.append(LoggedSet(sortOrder: index))
        }
        return entry
    }

    @discardableResult
    static func addSet(to entry: LoggedExercise) -> LoggedSet {
        let set = LoggedSet(sortOrder: (entry.sets.map(\.sortOrder).max() ?? -1) + 1)
        entry.sets.append(set)
        return set
    }

    /// Completed sets of the last finished session that included the exercise, other than the given session.
    static func previousSets(for exercise: Exercise?, before session: WorkoutSession?) -> [LoggedSet] {
        guard let exercise else { return [] }
        let entry = exercise.history.first { entry in
            guard let entrySession = entry.session else { return false }
            if let session, entrySession.persistentModelID == session.persistentModelID { return false }
            if let session { return entrySession.startedAt < session.startedAt }
            return true
        }
        return entry?.completedSets ?? []
    }

    /// The set performed at the same position last time, falling back to the last set performed.
    static func previousSet(at index: Int, in previous: [LoggedSet]) -> LoggedSet? {
        index < previous.count ? previous[index] : previous.last
    }

    /// Marks a set as done, filling empty fields with what was performed last time.
    static func complete(_ set: LoggedSet, previous: LoggedSet?, at date: Date = .now) {
        if set.load == nil { set.load = previous?.load }
        if set.reps == nil { set.reps = previous?.reps }
        set.completedAt = date
    }

    /// Swaps the performed exercise, e.g. for one of the planned substitutions.
    static func swap(_ entry: LoggedExercise, to exercise: Exercise) {
        entry.exercise = exercise
        for set in entry.sets where !set.isCompleted {
            set.load = nil
            set.reps = nil
        }
    }

    /// Ends the session, dropping sets that were never completed and exercises without any sets left.
    static func finish(_ session: WorkoutSession, in context: ModelContext, at date: Date = .now) {
        session.endedAt = max(date, session.startedAt)

        for entry in session.entries {
            for set in entry.sets where !set.isCompleted {
                entry.sets.removeAll { $0.persistentModelID == set.persistentModelID }
                context.delete(set)
            }
            if entry.sets.isEmpty {
                session.entries.removeAll { $0.persistentModelID == entry.persistentModelID }
                context.delete(entry)
            }
        }
    }
}
