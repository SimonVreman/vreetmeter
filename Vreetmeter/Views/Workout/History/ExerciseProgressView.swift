import SwiftUI
import SwiftData
import Charts

private struct ProgressPoint: Identifiable {
    let date: Date
    let metric: String
    let value: Double

    var id: String { "\(metric)-\(date.timeIntervalSinceReferenceDate)" }
}

struct ExerciseProgressView: View {
    @Bindable var exercise: Exercise

    private var history: [LoggedExercise] { exercise.history }

    private var points: [ProgressPoint] {
        history.reversed().flatMap { entry -> [ProgressPoint] in
            guard let date = entry.session?.startedAt else { return [] }
            var points: [ProgressPoint] = []
            if let oneRepMax = entry.bestSet?.estimatedOneRepMax {
                points.append(ProgressPoint(date: date, metric: "Estimated 1RM", value: oneRepMax))
            }
            if let topLoad = entry.completedSets.compactMap(\.load).max() {
                points.append(ProgressPoint(date: date, metric: "Top load", value: topLoad))
            }
            return points
        }
    }

    var body: some View {
        List {
            let data = points
            if data.isEmpty {
                ContentUnavailableView("No history yet", systemImage: "chart.line.uptrend.xyaxis", description: Text("Log this exercise in a workout to see your progress."))
            } else {
                Section("Progress (kg)") {
                    Chart(data) { point in
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value("Load", point.value)
                        ).foregroundStyle(by: .value("Metric", point.metric))

                        PointMark(
                            x: .value("Date", point.date),
                            y: .value("Load", point.value)
                        ).foregroundStyle(by: .value("Metric", point.metric))
                    }.chartForegroundStyleScale(["Estimated 1RM": Color.red, "Top load": Color.blue])
                        .chartXAxis {
                            AxisMarks(format: Date.FormatStyle().day(.defaultDigits).month(.abbreviated))
                        }
                        .chartYScale(domain: .automatic(includesZero: false))
                        .frame(height: 240)
                        .padding(.vertical, 8)
                }
            }

            Section("Details") {
                TextField("Instructions", text: Binding(
                    get: { exercise.instructions ?? "" },
                    set: { exercise.instructions = $0.isEmpty ? nil : $0 }
                ), axis: .vertical)
                TextField("Video link", text: Binding(
                    get: { exercise.videoURL ?? "" },
                    set: { exercise.videoURL = $0.isEmpty ? nil : $0 }
                )).keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                if let link = exercise.videoURL, let url = URL(string: link), url.scheme != nil {
                    Link("Watch demo", destination: url)
                }
            }

            ForEach(history) { entry in
                if let session = entry.session {
                    Section(session.startedAt.formatted(date: .abbreviated, time: .omitted) + " · " + session.title) {
                        ForEach(Array(entry.completedSets.enumerated()), id: \.element.id) { index, set in
                            HStack {
                                Text("Set \(index + 1)").foregroundStyle(.secondary)
                                Spacer()
                                Text(set.summary).monospacedDigit()
                            }
                        }
                    }
                }
            }
        }.navigationTitle(exercise.name)
    }
}
