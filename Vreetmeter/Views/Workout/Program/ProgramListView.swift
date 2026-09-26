import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ProgramListView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \WorkoutProgram.createdAt) private var programs: [WorkoutProgram]

    @State private var showImporter = false
    @State private var showNewProgramAlert = false
    @State private var newProgramName = ""
    @State private var importError: String?

    private func createProgram() {
        let name = newProgramName.trimmingCharacters(in: .whitespacesAndNewlines)
        newProgramName = ""
        if name.isEmpty { return }

        let program = WorkoutProgram(name: name)
        modelContext.insert(program)
        if programs.isEmpty { try? WorkoutPlanner.activate(program, in: modelContext) }
    }

    private func importProgram(_ result: Result<URL, Error>) {
        // Persist pending changes first, so a failed import can be rolled back on its own.
        try? modelContext.save()
        do {
            let url = try result.get()
            let accessing = url.startAccessingSecurityScopedResource()
            defer { if accessing { url.stopAccessingSecurityScopedResource() } }

            let template = try ProgramTemplateCoder.decode(try Data(contentsOf: url))
            let program = try ProgramTemplateCoder.importProgram(template, into: modelContext)
            if !programs.contains(where: \.isActive) { try WorkoutPlanner.activate(program, in: modelContext) }
            try modelContext.save()
        } catch {
            modelContext.rollback()
            importError = error.localizedDescription
        }
    }

    private func delete(_ program: WorkoutProgram) {
        modelContext.delete(program)
    }

    var body: some View {
        List {
            ForEach(programs) { program in
                NavigationLink(value: program) {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(program.name).font(.headline)
                            if program.isActive {
                                Text("Active")
                                    .font(.caption2).fontWeight(.bold)
                                    .padding(.horizontal, 6).padding(.vertical, 2)
                                    .background(.green.opacity(0.2), in: .capsule)
                            }
                        }
                        Text("\(program.weeks.count) weeks · \(program.trainingDays.count) workouts")
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                }.swipeActions(edge: .trailing) {
                    Button("Delete", systemImage: "trash", role: .destructive) { delete(program) }
                }.swipeActions(edge: .leading) {
                    if !program.isActive {
                        Button("Activate", systemImage: "checkmark") { try? WorkoutPlanner.activate(program, in: modelContext) }
                            .tint(.green)
                    }
                }
            }
        }.overlay {
            if programs.isEmpty {
                ContentUnavailableView {
                    Label("No programs", systemImage: "list.bullet.rectangle")
                } description: {
                    Text("Create a program, or import one from a JSON template.")
                } actions: {
                    Button("New program") { showNewProgramAlert = true }
                        .buttonStyle(.borderedProminent)
                    Button("Import template") { showImporter = true }
                }
            }
        }.navigationTitle("Programs")
            .toolbar {
                Menu("Add", systemImage: "plus") {
                    Button("New program", systemImage: "square.and.pencil") { showNewProgramAlert = true }
                    Button("Import template", systemImage: "square.and.arrow.down") { showImporter = true }
                }
            }
            .alert("New program", isPresented: $showNewProgramAlert) {
                TextField("Name", text: $newProgramName)
                Button("Cancel", role: .cancel) { newProgramName = "" }
                Button("Create", action: createProgram)
            }
            .alert("Import failed", isPresented: Binding(get: { importError != nil }, set: { if !$0 { importError = nil } })) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(importError ?? "")
            }
            .fileImporter(isPresented: $showImporter, allowedContentTypes: [.json], onCompletion: importProgram)
    }
}
