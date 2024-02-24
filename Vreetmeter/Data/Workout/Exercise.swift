
import Foundation
import SwiftData

@Model
class Exercise: Identifiable, Hashable {
    @Attribute(.unique) var id: UUID
    @Attribute(.unique) var name: String
    var video: String
    var instruction: String?
    
    init(name: String, video: String, instruction: String?) {
        self.id = UUID()
        self.name = name
        self.video = video
        self.instruction = instruction
    }
}
