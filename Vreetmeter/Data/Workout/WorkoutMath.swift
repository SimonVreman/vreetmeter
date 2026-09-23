import Foundation

nonisolated enum WorkoutMath {
    /// Epley estimate of the one-rep max, nil when no reps were performed.
    static func estimatedOneRepMax(load: Double, reps: Int) -> Double? {
        if reps <= 0 { return nil }
        if reps == 1 { return load }
        return load * (1 + Double(reps) / 30)
    }

    static func formatLoad(_ load: Double?) -> String {
        guard let load else { return "–" }
        return load.formatted(.number.grouping(.never).precision(.fractionLength(0...2)))
    }

    /// Parses user input like "82.5" or "82,5", nil for empty or invalid input.
    static func parseLoad(_ text: String) -> Double? {
        let normalized = text.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: ",", with: ".")
        if normalized.isEmpty { return nil }
        return Double(normalized)
    }

    /// Formats a rest range in seconds, e.g. (120, 180) as "2-3 min" and (45, nil) as "45 s".
    static func formatRest(min: Int?, max: Int?) -> String? {
        guard let lower = min ?? max else { return nil }
        let upper = max ?? lower
        let useMinutes = upper >= 60
        
        func format(_ seconds: Int) -> String {
            if !useMinutes { return String(seconds) }
            return (Double(seconds) / 60).formatted(.number.precision(.fractionLength(0...1)))
        }
        
        let lowerText = format(lower)
        let upperText = format(upper)
        let range = lower == upper ? lowerText : "\(lowerText)-\(upperText)"
        return range + (useMinutes ? " min" : " s")
    }

    /// Parses rest descriptions like "~2-3 min", "0.5-1 min", "90 s" or "90" (seconds) into a range of seconds.
    static func parseRest(_ text: String) -> (min: Int, max: Int)? {
        let lowered = text.lowercased()
            .replacingOccurrences(of: "~", with: "")
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespaces)
        if lowered.isEmpty { return nil }

        let isMinutes = lowered.contains("m")
        let numbers = lowered
            .components(separatedBy: CharacterSet(charactersIn: "0123456789.").inverted)
            .compactMap { Double($0) }
        guard let first = numbers.first else { return nil }
        let last = numbers.count > 1 ? numbers[1] : first

        let multiplier = isMinutes ? 60.0 : 1.0
        return (Int((first * multiplier).rounded()), Int((last * multiplier).rounded()))
    }
}
