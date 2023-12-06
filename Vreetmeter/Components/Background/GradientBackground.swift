
import SwiftUI

struct GradientBackground: View {
    var body: some View {
        ZStack(content: {
            RadialGradient(
                gradient: Gradient(colors: [.purple, .clear]),
                center: UnitPoint(x: 0.7, y: 0.4), startRadius: 0, endRadius: 250)
            .blur(radius: 40)
            RadialGradient(
                gradient: Gradient(colors: [.green, .clear]),
                center: UnitPoint(x: 0.1, y: 0.2), startRadius: 0, endRadius: 300)
            RadialGradient(
                gradient: Gradient(colors: [.cyan, .clear]),
                center: UnitPoint(x: 0.8, y: 0), startRadius: 0, endRadius: 300)
        }).background(Color(UIColor.systemGray6))
    }
}

#Preview {
    GradientBackground()
        .ignoresSafeArea()
}
