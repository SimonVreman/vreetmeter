
import SwiftUI

let FAT_SCORE_RANGE: ClosedRange<Double> = 0...0.7
let PROTEIN_SCORE_RANGE: ClosedRange<Double> = 0...0.8
let SCORE_STEP: Double = 0.05

extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        return Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}

struct GuessForm: View {
    enum FocusedField { case calories }

    @Binding var calories: Double
    @Binding var fatScore: Double
    @Binding var proteinScore: Double

    @FocusState private var focusedField: FocusedField?

    private func scoreLabel(_ value: Double, range: ClosedRange<Double>) -> String {
        let position = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        switch position {
        case ..<0.2: return "Very low"
        case ..<0.4: return "Low"
        case ..<0.6: return "Moderate"
        case ..<0.8: return "High"
        default: return "Very high"
        }
    }

    private func scoreRow(
        title: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        minimumLabel: String,
        maximumLabel: String,
        tint: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                Spacer()
                Text(scoreLabel(value.wrappedValue, range: range)).foregroundStyle(.secondary)
            }
            Slider(value: value, in: range, step: SCORE_STEP) {
                Text(title)
            } minimumValueLabel: {
                Text(minimumLabel).font(.caption).foregroundStyle(.secondary)
            } maximumValueLabel: {
                Text(maximumLabel).font(.caption).foregroundStyle(.secondary)
            }.tint(tint)
        }
    }

    var body: some View {
        Form {
            Section {
                LabeledContent {
                    TextField("0", value: $calories, formatter: NumberFormatter()).keyboardType(.decimalPad)
                        .fixedSize(horizontal: true, vertical: false)
                        .focused($focusedField, equals: .calories)
                        .onAppear { focusedField = .calories }
                } label: {
                    Text("Calories")
                }
                scoreRow(
                    title: "Fat",
                    value: $fatScore,
                    range: FAT_SCORE_RANGE,
                    minimumLabel: "Lean",
                    maximumLabel: "Fatty",
                    tint: .orange
                )
                scoreRow(
                    title: "Protein",
                    value: $proteinScore,
                    range: PROTEIN_SCORE_RANGE,
                    minimumLabel: "Low",
                    maximumLabel: "High",
                    tint: .green
                )
            }
        }.scrollContentBackground(.hidden)
            .contentMargins(.top, 0, for: .scrollContent)
            .scrollBounceBehavior(.basedOnSize)
    }
}


#Preview {
    GuessForm(
        calories: .constant(500),
        fatScore: .constant(0.3),
        proteinScore: .constant(0.25)
    ).padding(16)
}
