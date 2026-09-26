import SwiftUI
import SwiftData

struct ProgramWeekView: View {
    @Bindable var week: ProgramWeek

    @Environment(\.modelContext) private var modelContext

    private var days: [ProgramDay] { week.sortedDays }

    private func addDay(kind: ProgramDayKind) {
        let name = kind == .training ? "Workout \(week.days.filter { $0.kind == .training }.count + 1)" : kind.label
        week.days.append(ProgramDay(name: name, sortOrder: week.days.count, kind: kind))
    }

    private func onDelete(at offsets: IndexSet) {
        let sorted = days
        for index in offsets {
            week.days.removeAll { $0.persistentModelID == sorted[index].persistentModelID }
            modelContext.delete(sorted[index])
        }
        ProgramEditing.renumber(week.sortedDays) { $0.sortOrder = $1 }
    }

    var body: some View {
        List {
            Section {
                TextField("Name", text: $week.name)
                TextField("Block", text: Binding(
                    get: { week.block ?? "" },
                    set: { week.block = $0.isEmpty ? nil : $0 }
                ))
                TextField("Note, e.g. deload", text: Binding(
                    get: { week.note ?? "" },
                    set: { week.note = $0.isEmpty ? nil : $0 }
                ), axis: .vertical)
            }

            Section("Days") {
                ForEach(days) { day in
                    NavigationLink(value: day) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(day.name).foregroundStyle(day.kind == .training ? Color.primary : Color.secondary)
                            if day.kind == .training {
                                Text("\(day.exercises.count) exercises").font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }.swipeActions(edge: .leading) {
                        Button("Duplicate", systemImage: "plus.square.on.square") { ProgramEditing.duplicate(day) }
                            .tint(.blue)
                    }
                }.onDelete(perform: onDelete)
                    .onMove { ProgramEditing.move(days, fromOffsets: $0, toOffset: $1) { $0.sortOrder = $1 } }

                Menu {
                    ForEach(ProgramDayKind.allCases, id: \.self) { kind in
                        Button(kind.label) { addDay(kind: kind) }
                    }
                } label: {
                    Label("Add day", systemImage: "plus")
                }
            }
        }.navigationTitle(week.name)
            .toolbar { EditButton() }
    }
}
