import Foundation
import SwiftData

/// Structural edits of programs shared by the editor views.
enum ProgramEditing {
    /// Applies a list move to the sort order of already sorted items.
    static func move<T>(_ sorted: [T], fromOffsets source: IndexSet, toOffset destination: Int, setSortOrder: (T, Int) -> Void) {
        var copy = sorted
        copy.move(fromOffsets: source, toOffset: destination)
        for (index, item) in copy.enumerated() { setSortOrder(item, index) }
    }

    /// Renumbers sort orders after items were removed.
    static func renumber<T>(_ sorted: [T], setSortOrder: (T, Int) -> Void) {
        for (index, item) in sorted.enumerated() { setSortOrder(item, index) }
    }

    @discardableResult
    static func addWeek(to program: WorkoutProgram) -> ProgramWeek {
        let week = ProgramWeek(name: "Week \(program.weeks.count + 1)", sortOrder: program.weeks.count)
        program.weeks.append(week)
        return week
    }

    /// Inserts a copy of the week, including its days and exercises, directly after it.
    @discardableResult
    static func duplicate(_ week: ProgramWeek) -> ProgramWeek? {
        guard let program = week.program else { return nil }
        for other in program.weeks where other.sortOrder > week.sortOrder { other.sortOrder += 1 }

        let copy = ProgramWeek(name: nextName(after: week.name, in: program.weeks.map(\.name)), sortOrder: week.sortOrder + 1, block: week.block, note: week.note)
        program.weeks.append(copy)
        for day in week.sortedDays {
            copy.days.append(self.copy(day, sortOrder: day.sortOrder))
        }
        return copy
    }

    /// Inserts a copy of the day, including its exercises, directly after it.
    @discardableResult
    static func duplicate(_ day: ProgramDay) -> ProgramDay? {
        guard let week = day.week else { return nil }
        for other in week.days where other.sortOrder > day.sortOrder { other.sortOrder += 1 }

        let copy = self.copy(day, sortOrder: day.sortOrder + 1)
        week.days.append(copy)
        return copy
    }

    private static func copy(_ day: ProgramDay, sortOrder: Int) -> ProgramDay {
        let copy = ProgramDay(name: day.name, sortOrder: sortOrder, kind: day.kind)
        for planned in day.sortedExercises {
            let plannedCopy = PlannedExercise(sortOrder: planned.sortOrder)
            copy.exercises.append(plannedCopy)
            self.copy(planned, into: plannedCopy)
        }
        return copy
    }

    private static func copy(_ planned: PlannedExercise, into copy: PlannedExercise) {
        copy.exercise = planned.exercise
        copy.substitutions = planned.substitutions
        copy.supersetGroup = planned.supersetGroup
        copy.warmupSets = planned.warmupSets
        copy.workingSets = planned.workingSets
        copy.repTarget = planned.repTarget
        copy.earlyRPE = planned.earlyRPE
        copy.lastRPE = planned.lastRPE
        copy.restMinSeconds = planned.restMinSeconds
        copy.restMaxSeconds = planned.restMaxSeconds
        copy.intensityTechnique = planned.intensityTechnique
        copy.notes = planned.notes
    }

    /// "Week 4" becomes "Week 5" when that name is free, anything else gets a " (copy)" suffix.
    static func nextName(after name: String, in existing: [String]) -> String {
        if let range = name.range(of: #"\d+$"#, options: .regularExpression), let number = Int(name[range]) {
            let candidate = name.replacingCharacters(in: range, with: String(number + 1))
            if !existing.contains(candidate) { return candidate }
        }
        return name + " (copy)"
    }
}
