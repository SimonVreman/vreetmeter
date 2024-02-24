
import Foundation
import SwiftData

@Model
class Exercise {
    @Attribute(.unique) var name: String
    var video: String
    var instruction: String?
    
    init(name: String, video: String, instruction: String?) {
        self.name = name
        self.video = video
        self.instruction = instruction
    }
}
