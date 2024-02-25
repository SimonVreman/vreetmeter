
import SwiftUI
import SwiftData

struct ExerciseTemplateView: View {
    var template: ExerciseTemplate
    
    @Environment(\.modelContext) private var modelContext
    
    private var sets: [SetTemplate] {
        template.sets.sorted { a, b in a.sortOrder < b.sortOrder }
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
                    Text("\(set.sortOrder + 1)")
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
            Label("No sets added", systemImage: "figure.strengthtraining.traditional")
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
