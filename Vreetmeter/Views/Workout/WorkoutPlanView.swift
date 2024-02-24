
import SwiftUI

private struct WorkoutDay: Identifiable {
    var id: UUID
    var template: WorkoutTemplate?
}

struct WorkoutPlanView: View {
    var plan: WorkoutPlan
    
    private var days: [WorkoutDay] {
        var days: [WorkoutDay] = []
        for i in 0...(plan.workouts.count + plan.restDays.count) {
            if (plan.restDays.contains(i)) { days.append(WorkoutDay(id: UUID())) }
            let workout = plan.workouts[plan.restDays.filter { $0 < i }.count]
            days.append(WorkoutDay(id: workout.id, template: workout))
        }
        return days
    }
    
    var body: some View {
        List {
            ForEach(days) { day in
                if day.template == nil {
                    Text("Rest day")
                } else {
                    NavigationLink(day.template!.name, value: day.template!)
                }
            }
        }.navigationTitle(plan.name)
    }
}
