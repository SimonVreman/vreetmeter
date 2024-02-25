
import SwiftUI
import SwiftData

struct WorkoutPlanView: View {
    var plan: WorkoutPlan
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var showEditorSheet = false
    
    @Query var days: [WorkoutPlanDay]

    init(plan: WorkoutPlan) {
        self.plan = plan
        
        let planId = plan.id
        let predicate = #Predicate<WorkoutPlanDay> { day in
            day.plan?.id == planId
        }
        _days = Query(filter: predicate, sort: \.sortOrder)
    }
    
    private func addRestDay() {
        let restDay = WorkoutPlanDay(plan: plan)
        plan.days.append(restDay)
    }
    
    private func onDelete(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(days[index])
        }
        updateSortOrder(basedOn: days)
    }
    
    private func onMove(fromOffsets source: IndexSet, toOffset destination: Int) {
        var copy = days
        copy.move(fromOffsets: source, toOffset: destination)
        updateSortOrder(basedOn: copy)
    }
    
    private func updateSortOrder(basedOn order: [WorkoutPlanDay]) {
        for (index, day) in order.enumerated() {
            day.sortOrder = index
        }
    }
    
    var body: some View {
        VStack {
            if days.isEmpty {
                emptyView
            } else {
                daysView
            }
        }.sheet(isPresented: $showEditorSheet) {
            WorkoutTemplateEditorSheet(plan: plan)
        }.navigationTitle(plan.name)
    }
    
    private var daysView: some View {
        VStack(spacing: 0) {
            List {
                ForEach(days) { day in
                    if let workout = day.workout {
                        NavigationLink(workout.name, destination: WorkoutTemplateView(template: workout))
                    } else {
                        Text("Rest day")
                    }
                }.onDelete(perform: onDelete)
                    .onMove(perform: onMove)
            }.listStyle(.grouped)
            
            Spacer(minLength: 0)
            Divider()
            
            HStack(spacing: 0) {
                Button("Workout", systemImage: "plus") {
                    showEditorSheet = true
                }.padding(16)
                    .frame(minWidth: 0, maxWidth: .infinity)
                
                Button("Rest day", systemImage: "plus") {
                    addRestDay()
                }.padding(16)
                    .frame(minWidth: 0, maxWidth: .infinity)
            }
        }.toolbar {
            EditButton()
        }
    }
    
    private var emptyView: some View {
        ContentUnavailableView {
            Label("No workouts", systemImage: "gym.bag.fill")
        } description: {
            Text("You don't have any workouts, create one now!")
        } actions: {
            Button {
                showEditorSheet = true
            } label: {
                Text("Add a workout")
            }.buttonStyle(.borderedProminent)
                .controlSize(.regular)
        }
    }
}
