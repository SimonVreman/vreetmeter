
import SwiftUI
import SwiftData

struct ExerciseTemplateView: View {
    var template: ExerciseTemplate
    
    @Environment(\.modelContext) private var modelContext
    
    @Query private var setsQuery: [SetTemplate]
    
    private var sets: [SetTemplate] {
        setsQuery.filter { $0.exercise == template } .sorted { a, b in a.sortOrder < b.sortOrder }
    }
    
    private func onDelete(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(sets[index])
        }
        updateSortOrder(basedOn: sets)
    }
    
    private func onMove(fromOffsets source: IndexSet, toOffset destination: Int) {
        var copy = sets
        copy.move(fromOffsets: source, toOffset: destination)
        updateSortOrder(basedOn: copy)
    }
    
    private func updateSortOrder(basedOn order: [SetTemplate]) {
        for (index, set) in order.enumerated() {
            set.sortOrder = index
        }
    }
    
    private func addNewSet() {
        // TODO: this cannot work one-on-one
        let set = SetTemplate(exercise: template)
        template.sets.append(set)
    }
    
    var body: some View {
        VStack {
            if sets.isEmpty {
                emptyView
            } else {
                setsView
            }
        }.navigationTitle(template.exercise.name)
    }
    
    private var setsView: some View {
        VStack(spacing: 0) {
            List {
                ForEach(sets) { set in
                    SetRowView(set: set)
                }.onDelete(perform: onDelete)
                    .onMove(perform: onMove)
            }.listStyle(.grouped)
            
            Spacer(minLength: 0)
            Divider()
            
            HStack(spacing: 0) {
                Button("Add set", systemImage: "plus") {
                    addNewSet()
                }.padding(16)
                    .frame(minWidth: 0, maxWidth: .infinity)
            }
        }.toolbar {
            EditButton()
        }
    }
    
    private var emptyView: some View {
        ContentUnavailableView {
            Label("No sets added", systemImage: "tablecells")
        } description: {
            Text("This exercise has no sets yet, add one now!")
        } actions: {
            Button {
                addNewSet()
            } label: {
                Text("Add first set")
            }.buttonStyle(.borderedProminent)
                .controlSize(.regular)
        }
    }
}

private struct SetRowView: View {
    var set: SetTemplate
    
    @Query private var intensityTechniques: [IntensityTechnique]
    
    var body: some View {
        HStack {
            Text("\(set.sortOrder + 1)").font(.footnote)
                .frame(width: 24)
            
            VStack {
                Text("Repetitions").font(.caption)
                HStack {
                    TextField("min", text: Binding(
                        get: { if let min = set.repetitionRange.lowerLimit { String(min) } else { "" } },
                        set: { set.repetitionRange.lowerLimit = Int($0) }
                    )).textFieldStyle(.roundedBorder)
                    
                    TextField("max", text: Binding(
                        get: { if let min = set.repetitionRange.upperLimit { String(min) } else { "" } },
                        set: { set.repetitionRange.upperLimit = Int($0) }
                    )).textFieldStyle(.roundedBorder)
                }
                
                Picker("Intensity technique", selection: Binding(
                    get: { set.intensitiyTechnique },
                    set: { set.intensitiyTechnique = $0 }
                )) {
                    ForEach(intensityTechniques) { technique in
                        Text(technique.name).tag(technique as IntensityTechnique)
                    }
                }
            }
        }
    }
}
