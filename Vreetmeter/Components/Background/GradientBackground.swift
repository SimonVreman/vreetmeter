
import SwiftUI

struct GradientBackground: View {
    var colors: [Color]
    
    var body: some View {
        ZStack {
            RadialGradient(
                gradient: Gradient(colors: [colors[0], .clear]),
                center: UnitPoint(x: 0.7, y: 0.4), startRadius: 0, endRadius: 250)
            RadialGradient(
                gradient: Gradient(colors: [colors[1], .clear]),
                center: UnitPoint(x: 0.1, y: 0.2), startRadius: 0, endRadius: 300)
            RadialGradient(
                gradient: Gradient(colors: [colors[2], .clear]),
                center: UnitPoint(x: 0.8, y: 0), startRadius: 0, endRadius: 300)
        }.blur(radius: 40)
            .padding(-80)
    }
}

#Preview {
    ScrollView {
        GradientBackground(colors: [.purple, .green, .cyan])
            .ignoresSafeArea().frame(height: 600)
        GradientBackground(colors: [.orange, .blue, .green])
            .ignoresSafeArea().frame(height: 600)
    }
}
