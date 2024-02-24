
import Foundation
import SwiftData

@Model
class Exercise: Identifiable {
    @Attribute(.unique) let id: UUID
    @Attribute(.unique) var name: String
    var video: String?
    var instruction: String?
    
    init(name: String) {
        self.id = UUID()
        self.name = name
    }
}
