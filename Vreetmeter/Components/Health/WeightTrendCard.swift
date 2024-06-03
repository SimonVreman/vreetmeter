
import SwiftUI

struct WeightTrendCard: View {
    private let rangeSize = 14
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
        VStack(alignment: .leading, spacing: 4) {
            Text("14-day difference").font(.title2).bold().padding(.top)
            GroupBox {
                Grid(alignment: .leading, horizontalSpacing: 24) {
                    ForEach(0..<10) {
                        let (first, second) = getRanges(length: rangeSize, offset: $0 * rangeSize)
                        let date = Calendar.current.date(byAdding: .day, value: -rangeSize * ($0 + 1), to: Date.now)!
                        
                        WeightTrendRow(
                            label: date.formatted(.dateTime.day().month(.abbreviated)),
                            firstRange: first,
                            secondRange: second
                        )
                    }
                }
            }.cardBackgroundAndShadow()
        }
    }
}

#Preview {
    WeightTrendCard(data: [
        NumericalDatePoint(date: Date.now, value: 74.2),
        NumericalDatePoint(date: Date.now, value: 75.1),
        NumericalDatePoint(date: Date.now, value: 73.5),
        NumericalDatePoint(date: Calendar.current.date(byAdding: .day, value: -8, to: Date.now)!, value: 72.9),
        NumericalDatePoint(date: Calendar.current.date(byAdding: .day, value: -16, to: Date.now)!, value: 72.7),
        NumericalDatePoint(date: Calendar.current.date(byAdding: .day, value: -20, to: Date.now)!, value: 72.9),
        NumericalDatePoint(date: Calendar.current.date(byAdding: .day, value: -26, to: Date.now)!, value: 71.7),
        NumericalDatePoint(date: Calendar.current.date(byAdding: .day, value: -31, to: Date.now)!, value: 70.9),
        NumericalDatePoint(date: Calendar.current.date(byAdding: .day, value: -36, to: Date.now)!, value: 72.7),
        NumericalDatePoint(date: Calendar.current.date(byAdding: .day, value: -42, to: Date.now)!, value: 72.7)
    ])
}
