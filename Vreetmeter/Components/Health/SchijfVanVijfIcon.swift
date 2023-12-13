
import SwiftUI

private struct SchijfVanVijfSegmentPath: Shape {
    var start: Double
    var end: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        path.move(to: center)
        path.addArc(
            center: center,
            radius: rect.midX,
            startAngle: Angle(degrees: 360 * start),
            endAngle: Angle(degrees: 360 * end),
            clockwise: false
        )
        path.closeSubpath()
        
        return path
    }
}

private struct SchijfVanVijfSegment: View {
    var start: Double
    var end: Double
    var size: Double
    
    var body: some View {
        let path = SchijfVanVijfSegmentPath(start: start, end: end)
        path.mask {
            path.fill(.white)
                .stroke(.black, style: StrokeStyle(lineWidth: size / 20, lineJoin: .round))
                .compositingGroup()
                .luminanceToAlpha()
        }
    }
}

struct SchijfVanVijfIcon: View {
    var highlighted: SchijfVanVijfCategory? = nil
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ZStack {
                    SchijfVanVijfSegment(start: -0.25, end: 0.05, size: proxy.size.width)
                        .if(highlighted == .vegetablesAndFruits, transform: {
                            $0.foregroundStyle(.green).scaleEffect(1.1)
                        })
                    SchijfVanVijfSegment(start: 0.05, end: 0.1, size: proxy.size.width)
                        .if(highlighted == .oilsAndFats, transform: {
                            $0.foregroundStyle(.yellow).scaleEffect(1.1)
                        })
                    SchijfVanVijfSegment(start: 0.1, end: 0.28, size: proxy.size.width)
                        .if(highlighted == .fishMeatDairyAndNuts, transform: {
                            $0.foregroundStyle(.pink).scaleEffect(1.1)
                        })
                    SchijfVanVijfSegment(start: 0.28, end: 0.55, size: proxy.size.width)
                        .if(highlighted == .breadGrainsAndPotatos, transform: {
                            $0.foregroundStyle(.orange).scaleEffect(1.1)
                        })
                    SchijfVanVijfSegment(start: 0.55, end: 0.75, size: proxy.size.width)
                        .if(highlighted == .waterTeaAndCoffee, transform: {
                            $0.foregroundStyle(.blue).scaleEffect(1.1)
                        })
                }.if(highlighted == nil, transform: {
                    $0.mask {
                        ZStack {
                            Rectangle().fill(.white).frame(width: proxy.size.width, height: proxy.size.height)
                            Rectangle()
                                .stroke(.black, style: StrokeStyle(lineWidth: proxy.size.width / 20))
                                .fill(.black)
                                .frame(width: proxy.size.width, height: proxy.size.width / 10)
                                .rotationEffect(Angle(degrees: 45))
                        }.compositingGroup()
                            .luminanceToAlpha()
                    }
                })
                
                if (highlighted == nil) {
                    RoundedRectangle(cornerRadius: proxy.size.width / 10)
                        .fill(.red)
                        .frame(width: proxy.size.width, height: proxy.size.height / 20)
                        .scaleEffect(1.2)
                        .rotationEffect(Angle(degrees: 45))
                }
            }.foregroundStyle(.secondary.tertiary).padding(proxy.size.width / 20)
        }.aspectRatio(contentMode: .fit)
    }
}

#Preview {
    VStack {
        SchijfVanVijfIcon(highlighted: nil)
        SchijfVanVijfIcon(highlighted: .vegetablesAndFruits)
        SchijfVanVijfIcon(highlighted: .oilsAndFats)
        SchijfVanVijfIcon(highlighted: .fishMeatDairyAndNuts)
        SchijfVanVijfIcon(highlighted: .breadGrainsAndPotatos)
        SchijfVanVijfIcon(highlighted: .waterTeaAndCoffee)
    }
}
