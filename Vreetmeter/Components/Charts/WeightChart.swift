
import SwiftUI
import Charts
import DebouncedOnChange

private struct NumericalTrendDatePoint: Identifiable {
    let date: Date
    let value: Double?
    let average: Double?
    let min: Double?
    let max: Double?
    
    var id: Date {
        self.date
    }
}

struct WeightChart: View {
    @State private var scrollPosition = Date.now
    @State private var verticalDomain: [Double] = [0, 0]
    @State private var dataWithTrend: [NumericalTrendDatePoint] = []
    
    var domain: [Date]
    var data: [NumericalDatePoint]
    var zones: Int
    
    let zonesInView: Double = 5
    
    private var zoneWidth: TimeInterval {
        return domain[0].distance(to: domain[1]).scaled(by: 1 / Double(zones))
    }
    
    private func updateDataWithTrend() {
        let pointsByDate = Dictionary(grouping: data, by: { $0.date.startOfDay })
        var currentDate = domain[0].startOfDay
        var allDates: [Date] = []
        var points: [NumericalTrendDatePoint] = []
        
        while currentDate <= domain[1] {
            allDates.append(currentDate)
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        for date in allDates {
            let numericalPoints = pointsByDate.filter { key, _ in
                let difference = date.timeIntervalSinceReferenceDate - key.timeIntervalSinceReferenceDate
                return difference >= 0 && difference <= zoneWidth
            }.flatMap { key, value in value }
            
            let value = pointsByDate[date.startOfDay]?.average()
            let min = numericalPoints.min()?.value
            let max = numericalPoints.max()?.value
            let average = numericalPoints.average()
            
            points.append(NumericalTrendDatePoint(date: date, value: value, average: average, min: min, max: max))
        }
        
        dataWithTrend = points
    }
    
    private func updateVerticalDomain() {
        let dataInView = data.filter { value in
            value.date >= scrollPosition && value.date <= (scrollPosition + zoneWidth * zonesInView)
        }
        let min = dataInView.min()?.value ?? 0
        let max = dataInView.max()?.value ?? 0
        let padding = (max - min)
        verticalDomain = [min - padding, max + padding]
    }
    
    var body: some View {
        Chart(dataWithTrend) {
            if $0.min != nil && $0.max != nil {
                AreaMark(
                    x: .value("Day", $0.date),
                    yStart: .value("Weight (higher bound)", $0.min!),
                    yEnd: .value("Weight (lower bound)", $0.max!)
                ).foregroundStyle(.gray.opacity(0.2))
                    .interpolationMethod(.catmullRom)
            }
            
            if $0.average != nil {
                LineMark(
                    x: .value("Day", $0.date),
                    y: .value("Weight (average)", $0.average!)
                ).foregroundStyle(.gray)
                    .lineStyle(StrokeStyle(lineWidth: 3, dash: [5, 5]))
                    .interpolationMethod(.catmullRom)
            }
            
            if $0.value != nil {
                LineMark(
                    x: .value("Day", $0.date),
                    y: .value("Weight", $0.value!),
                    series: .value("Weight", "")
                ).foregroundStyle(.red)
                
                PointMark(
                    x: .value("Day", $0.date),
                    y: .value("Weight", $0.value!)
                ).foregroundStyle(.red)
            }
        }.chartXAxis {
            AxisMarks(format: Date.FormatStyle().day(.defaultDigits).month(.abbreviated))
        }.chartYScale(domain: verticalDomain)
            .chartXScale(domain: domain)
            .chartScrollableAxes(.horizontal)
            .chartScrollPosition(x: $scrollPosition)
            .chartXVisibleDomain(length: zoneWidth * zonesInView)
            .onAppear {
                updateDataWithTrend()
                scrollPosition = Date.now - zoneWidth * zonesInView
            }.onChange(of: scrollPosition, debounceTime: .seconds(0.1)) { _ in
                updateVerticalDomain()
            }.animation(.easeOut, value: verticalDomain)
    }
}

#Preview {
    WeightChart(
        domain: [Calendar.current.date(byAdding: .day, value: -28, to: Date.now)!, Date.now],
        data: [
            NumericalDatePoint(date: Calendar.current.date(byAdding: .day, value: -2, to: Date.now)!, value: 70),
            NumericalDatePoint(date: Calendar.current.date(byAdding: .day, value: -3, to: Date.now)!, value: 420),
            NumericalDatePoint(date: Calendar.current.date(byAdding: .day, value: -5, to: Date.now)!, value: 480),
            NumericalDatePoint(date: Calendar.current.date(byAdding: .day, value: -8, to: Date.now)!, value: 450),
            NumericalDatePoint(date: Calendar.current.date(byAdding: .day, value: -10, to: Date.now)!, value: 310),
            NumericalDatePoint(date: Calendar.current.date(byAdding: .day, value: -14, to: Date.now)!, value: 300),
            NumericalDatePoint(date: Calendar.current.date(byAdding: .day, value: -17, to: Date.now)!, value: 200),
            NumericalDatePoint(date: Calendar.current.date(byAdding: .day, value: -20, to: Date.now)!, value: 240),
        ],
        zones: 4
    )
}
