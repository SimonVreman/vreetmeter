
import SwiftUI
import SwiftData

private struct WorkoutDay: Identifiable {
    var id: UUID
    var template: WorkoutTemplate?
}

struct WorkoutPlanView: View {
    var plan: WorkoutPlan
    
    @State private var showTemplateEditorSheet = false
    
    private var days: [WorkoutDay] {
        var days: [WorkoutDay] = []
        var restDaysAdded = 0
        let orderedWorkouts = plan.workouts.sorted { a, b in a.sortOrder < b.sortOrder }
        for i in 0..<(plan.workouts.count + plan.restDays.count) {
            if (plan.restDays.contains(i)) {
                days.append(WorkoutDay(id: UUID()))
                restDaysAdded += 1
            } else {
                let workout = orderedWorkouts[i - restDaysAdded]
                days.append(WorkoutDay(id: workout.id, template: workout))
            }
        }
        return days
    }
    
    private func addRestDay() {
        plan.restDays.append(days.count)
    }
    
    var body: some View {
        VStack {
            List {
                ForEach(days) { day in
                    if day.template == nil {
                        Text("Rest day")
                    } else {
                        NavigationLink(day.template!.name, value: day.template!)
                    }
                }
            }
            
            List {
                Button("Add workout") { showTemplateEditorSheet = true }
                Button("Add rest day") { addRestDay() }
            }
        }.sheet(isPresented: $showTemplateEditorSheet) {
            WorkoutTemplateEditorSheet(plan: plan)
        }.navigationTitle(plan.name)
    }
}
