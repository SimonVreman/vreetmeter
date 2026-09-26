import SwiftUI
import SwiftData

struct ProgramView: View {
    @Bindable var program: WorkoutProgram

    @Environment(\.modelContext) private var modelContext

    private var weeks: [ProgramWeek] { program.sortedWeeks }

    private var exportFile: ProgramTemplateFile? {
        guard let data = try? ProgramTemplateCoder.encode(ProgramTemplateCoder.template(for: program)) else { return nil }
        return ProgramTemplateFile(name: program.name, data: data)
    }

    private func onDelete(at offsets: IndexSet) {
        let sorted = weeks
        for index in offsets {
            program.weeks.removeAll { $0.persistentModelID == sorted[index].persistentModelID }
            modelContext.delete(sorted[index])
        }
        ProgramEditing.renumber(program.sortedWeeks) { $0.sortOrder = $1 }
    }

    var body: some View {
        List {
            Section {
                TextField("Name", text: $program.name)
                TextField("Notes", text: Binding(
                    get: { program.notes ?? "" },
                    set: { program.notes = $0.isEmpty ? nil : $0 }
                ), axis: .vertical)

                if program.isActive {
                    Button("Start over from the first workout") { WorkoutPlanner.restart(program) }
                } else {
                    Button("Make active program") { try? WorkoutPlanner.activate(program, in: modelContext) }
                }
            }

            Section("Weeks") {
                ForEach(weeks) { week in
                    NavigationLink(value: week) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(week.name)
                            let details = [week.block, week.note].compactMap { $0 }.filter { !$0.isEmpty }
                            if !details.isEmpty {
                                Text(details.joined(separator: " · "))
                                    .font(.caption).foregroundStyle(.secondary).lineLimit(1)
                            }
                        }
                    }.contextMenu {
                        Button("Duplicate", systemImage: "plus.square.on.square") { ProgramEditing.duplicate(week) }
                    }.swipeActions(edge: .leading) {
                        Button("Duplicate", systemImage: "plus.square.on.square") { ProgramEditing.duplicate(week) }
                            .tint(.blue)
                    }
                }.onDelete(perform: onDelete)
                    .onMove { ProgramEditing.move(weeks, fromOffsets: $0, toOffset: $1) { $0.sortOrder = $1 } }

                Button("Add week", systemImage: "plus") { ProgramEditing.addWeek(to: program) }
            }
        }.navigationTitle(program.name)
            .toolbar {
                if let exportFile {
                    ShareLink(item: exportFile, preview: SharePreview(program.name))
                }
                EditButton()
            }
    }
}
