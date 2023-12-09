
import SwiftUI

@Observable class TrackingNavigationState {
    var selectionPath = NavigationPath()

    var date: Date = .now.startOfDay
    var meal: Meal?
    
    @MainActor func append(_ v: any Hashable) {
        self.selectionPath.append(v)
    }
    
    @MainActor func removeLast() {
        self.selectionPath.removeLast()
    }
}
