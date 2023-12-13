
import SwiftUI

struct WeightTrendCard: View {
    var data: [NumericalDatePoint]
    
    func getRanges(length: Int, offset: Int) -> (first: [NumericalDatePoint], second: [NumericalDatePoint]) {
        let end = Calendar.current.date(byAdding: .day, value: -offset, to: Date.now)!
        let middle = Calendar.current.date(byAdding: .day, value: -length, to: end)!
        let start = Calendar.current.date(byAdding: .day, value: -length, to: middle)!
        
        let firstRange = data.filter { $0.date >= start && $0.date < middle }
        let secondRange = data.filter { $0.date >= middle && $0.date < end }
        
        return (firstRange, secondRange)
    }

    var body: some View {
        GroupBox {
            Grid(alignment: .leading, horizontalSpacing: 16) {
                ForEach(0...2, id: \.self) {
                    let (first, second) = getRanges(length: 7, offset: $0 * 7)
                    WeightTrendRow(firstRange: first, secondRange: second)
                }
            }
        }.cardBackgroundAndShadow()
    }
}

#Preview {
    WeightTrendCard(data: [
        NumericalDatePoint(date: Date.now, value: 74.2),
        NumericalDatePoint(date: Date.now, value: 75.1),
        NumericalDatePoint(date: Date.now, value: 73.5),
        NumericalDatePoint(date: Calendar.current.date(byAdding: .day, value: -8, to: Date.now)!, value: 72.9),
        NumericalDatePoint(date: Calendar.current.date(byAdding: .day, value: -16, to: Date.now)!, value: 72.7)
    ])
}
