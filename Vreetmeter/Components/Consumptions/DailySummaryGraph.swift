
import SwiftUI
import Charts

struct DailySummaryGraph: View {
    var value: Int
    var color: Color
    var goal: Int
    var limit: Int?
    
    var body: some View {
        HStack(spacing: 4) {
            let overGoal = value > goal
            let overLimit = limit != nil && value > limit!
            Chart {
                
                // Main indicator
                BarMark(x: .value("", overGoal ? goal : value))
                    .foregroundStyle(color)
                
                // Tertiary, under goal indicator
                if !overGoal {
                    BarMark(x: .value("", goal - value))
                        .foregroundStyle(color.tertiary)
                }
                
                // Main under limit indicator
                if limit != nil && overGoal {
                    BarMark(x: .value("", (overLimit ? limit! : value) - goal))
                        .foregroundStyle(color)
                }
                
                // Tertiary, under limit indicitor
                if limit != nil && !overLimit {
                    BarMark(x: .value("", limit! - (overGoal ? value : goal)))
                        .foregroundStyle(color.quinary)
                }
                
                if limit != nil {
                    RuleMark(x: .value("", goal))
                        .foregroundStyle(Color(UIColor.secondarySystemGroupedBackground))
                        .lineStyle(.init(lineWidth: 2))
                }
                
            }.frame(height: 25)
                .chartXAxis(.hidden)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            if overLimit || (limit == nil && overGoal) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.yellow)
            }
        }.padding(1)
    }
}

#Preview {
    VStack {
        DailySummaryGraph(value: 0, color: .blue, goal: 200, limit: 300)
        DailySummaryGraph(value: 50, color: .blue, goal: 200, limit: 300)
        DailySummaryGraph(value: 100, color: .blue, goal: 200, limit: 300)
        DailySummaryGraph(value: 150, color: .blue, goal: 200, limit: 300)
        DailySummaryGraph(value: 200, color: .blue, goal: 200, limit: 300)
        DailySummaryGraph(value: 250, color: .blue, goal: 200, limit: 300)
        DailySummaryGraph(value: 300, color: .blue, goal: 200, limit: 300)
        DailySummaryGraph(value: 350, color: .blue, goal: 200, limit: 300)
        
        DailySummaryGraph(value: 0, color: .green, goal: 150)
        DailySummaryGraph(value: 50, color: .green, goal: 150)
        DailySummaryGraph(value: 100, color: .green, goal: 150)
        DailySummaryGraph(value: 150, color: .green, goal: 150)
        DailySummaryGraph(value: 200, color: .green, goal: 150)
        DailySummaryGraph(value: 250, color: .green, goal: 150)
        
        DailySummaryGraph(value: 40, color: .orange, goal: 50, limit: 80)
        DailySummaryGraph(value: 60, color: .orange, goal: 50, limit: 80)
        DailySummaryGraph(value: 90, color: .orange, goal: 50, limit: 80)
    }.padding(.horizontal, 16)
}
