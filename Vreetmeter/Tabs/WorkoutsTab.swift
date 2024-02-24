
import SwiftUI
import SwiftData

private enum WorkoutsDestination {
    case workoutPlanCollection
}

struct WorkoutsTab: View {
    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink("Workout plans", destination: WorkoutPlanCollectionView())
            }
        }
    }
}
