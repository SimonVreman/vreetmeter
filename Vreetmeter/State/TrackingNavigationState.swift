
import SwiftUI

@Observable class TrackingNavigationState {
    var selectionPath = NavigationPath()

    var date: Date = .now.startOfDay
    var meal: Meal?
    var consumptionSubmit: Bool = false
    
    @MainActor func append(_ v: any Hashable) {
        self.selectionPath.append(v)
    }
    
    @MainActor func removeLast() {
        self.selectionPath.removeLast()
    }
    
    @MainActor func productSaved() {
        if (self.selectionPath.count <= 1) {
            self.consumptionSubmit.toggle()
        } else {
            self.removeLast()
        }
    }
}
