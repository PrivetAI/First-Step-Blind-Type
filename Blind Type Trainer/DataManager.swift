import Foundation

enum PracticeMode: String, Codable, CaseIterable {
    case words = "Words"
    case sentences = "Sentences"
    case mixed = "Mixed"
}

struct SessionResult: Codable, Identifiable {
    let id: String
    let date: Date
    let wpm: Double
    let accuracy: Double
    let difficulty: String
    let wordsTyped: Int
    let mode: String
    let durationSeconds: Int

    init(wpm: Double, accuracy: Double, difficulty: String, wordsTyped: Int, mode: String = "Words", durationSeconds: Int = 60) {
        self.id = UUID().uuidString
        self.date = Date()
        self.wpm = wpm
        self.accuracy = accuracy
        self.difficulty = difficulty
        self.wordsTyped = wordsTyped
        self.mode = mode
        self.durationSeconds = durationSeconds
    }
}

struct Achievement: Identifiable {
    let id: String
    let title: String
    let description: String
    let isUnlocked: Bool
}

class DataManager: ObservableObject {
    static let shared = DataManager()

    @Published var sessions: [SessionResult] = []

    private let storageKey = "blind_type_sessions_v2"
    private let practiceTimeKey = "blind_type_practice_seconds"

    init() {
        loadSessions()
    }

    func saveSession(_ result: SessionResult) {
        sessions.append(result)
        addPracticeTime(result.durationSeconds)
        persistSessions()
    }

    var bestWPM: Double {
        sessions.map(\.wpm).max() ?? 0
    }

    var totalSessions: Int {
        sessions.count
    }

    var averageAccuracy: Double {
        guard !sessions.isEmpty else { return 0 }
        return sessions.map(\.accuracy).reduce(0, +) / Double(sessions.count)
    }

    var averageWPM: Double {
        guard !sessions.isEmpty else { return 0 }
        return sessions.map(\.wpm).reduce(0, +) / Double(sessions.count)
    }

    var recentWPMs: [Double] {
        Array(sessions.suffix(20).map(\.wpm))
    }

    var recentAccuracies: [Double] {
        Array(sessions.suffix(20).map(\.accuracy))
    }

    var last50Sessions: [SessionResult] {
        Array(sessions.suffix(50).reversed())
    }

    // MARK: - Time Tracking

    private func addPracticeTime(_ seconds: Int) {
        var times = loadPracticeTimes()
        let today = dateKey(for: Date())
        times[today] = (times[today] ?? 0) + seconds
        savePracticeTimes(times)
    }

    func practiceTimeToday() -> Int {
        let times = loadPracticeTimes()
        return times[dateKey(for: Date())] ?? 0
    }

    func practiceTimeThisWeek() -> Int {
        let times = loadPracticeTimes()
        let cal = Calendar.current
        let now = Date()
        var total = 0
        for i in 0..<7 {
            if let day = cal.date(byAdding: .day, value: -i, to: now) {
                total += times[dateKey(for: day)] ?? 0
            }
        }
        return total
    }

    func practiceTimeThisMonth() -> Int {
        let times = loadPracticeTimes()
        let cal = Calendar.current
        let now = Date()
        var total = 0
        for i in 0..<31 {
            if let day = cal.date(byAdding: .day, value: -i, to: now) {
                total += times[dateKey(for: day)] ?? 0
            }
        }
        return total
    }

    func totalPracticeTime() -> Int {
        let times = loadPracticeTimes()
        return times.values.reduce(0, +)
    }

    func formatTime(_ seconds: Int) -> String {
        if seconds < 60 {
            return "\(seconds) sec"
        } else if seconds < 3600 {
            let min = seconds / 60
            return "\(min) min"
        } else {
            let hrs = Double(seconds) / 3600.0
            return String(format: "%.1f hrs", hrs)
        }
    }

    private func dateKey(for date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: date)
    }

    private func loadPracticeTimes() -> [String: Int] {
        guard let data = UserDefaults.standard.data(forKey: practiceTimeKey),
              let decoded = try? JSONDecoder().decode([String: Int].self, from: data) else {
            return [:]
        }
        return decoded
    }

    private func savePracticeTimes(_ times: [String: Int]) {
        if let encoded = try? JSONEncoder().encode(times) {
            UserDefaults.standard.set(encoded, forKey: practiceTimeKey)
        }
    }

    // MARK: - Achievements

    func getAchievements() -> [Achievement] {
        return [
            Achievement(id: "first_session", title: "First Steps", description: "Complete your first session", isUnlocked: totalSessions >= 1),
            Achievement(id: "ten_sessions", title: "Getting Started", description: "Complete 10 sessions", isUnlocked: totalSessions >= 10),
            Achievement(id: "fifty_sessions", title: "Dedicated Typist", description: "Complete 50 sessions", isUnlocked: totalSessions >= 50),
            Achievement(id: "hundred_sessions", title: "Typing Master", description: "Complete 100 sessions", isUnlocked: totalSessions >= 100),
            Achievement(id: "wpm_30", title: "Warming Up", description: "Reach 30 WPM", isUnlocked: bestWPM >= 30),
            Achievement(id: "wpm_50", title: "Getting Fast", description: "Reach 50 WPM", isUnlocked: bestWPM >= 50),
            Achievement(id: "wpm_75", title: "Speed Demon", description: "Reach 75 WPM", isUnlocked: bestWPM >= 75),
            Achievement(id: "wpm_100", title: "First 100 WPM!", description: "Reach 100 WPM", isUnlocked: bestWPM >= 100),
            Achievement(id: "wpm_150", title: "Lightning Fingers", description: "Reach 150 WPM", isUnlocked: bestWPM >= 150),
            Achievement(id: "acc_90", title: "Accurate Typer", description: "Get 90% accuracy or higher", isUnlocked: sessions.contains { $0.accuracy >= 90 }),
            Achievement(id: "acc_95", title: "Precision King", description: "Get 95% accuracy or higher", isUnlocked: sessions.contains { $0.accuracy >= 95 }),
            Achievement(id: "acc_100", title: "Perfectionist", description: "Get 100% accuracy in a session", isUnlocked: sessions.contains { $0.accuracy >= 99.9 }),
            Achievement(id: "expert_mode", title: "Blind Master", description: "Complete a session on Expert", isUnlocked: sessions.contains { $0.difficulty == "Expert" }),
            Achievement(id: "all_modes", title: "Mode Explorer", description: "Try all practice modes", isUnlocked: hasTriedAllModes()),
            Achievement(id: "hour_practice", title: "Hour of Power", description: "Practice for 1 hour total", isUnlocked: totalPracticeTime() >= 3600),
            Achievement(id: "five_hours", title: "Dedicated Learner", description: "Practice for 5 hours total", isUnlocked: totalPracticeTime() >= 18000),
        ]
    }

    private func hasTriedAllModes() -> Bool {
        let modes = Set(sessions.map(\.mode))
        return modes.contains("Words") && modes.contains("Sentences") && modes.contains("Mixed")
    }

    // MARK: - Export

    func exportStatsText() -> String {
        var text = "Blind Type Trainer Stats\n"
        text += "========================\n"
        text += "Total Sessions: \(totalSessions)\n"
        text += "Best WPM: \(String(format: "%.0f", bestWPM))\n"
        text += "Average WPM: \(String(format: "%.0f", averageWPM))\n"
        text += "Average Accuracy: \(String(format: "%.1f", averageAccuracy))%\n"
        text += "Total Practice: \(formatTime(totalPracticeTime()))\n\n"
        text += "Session History:\n"
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        for session in sessions.suffix(50) {
            text += "\(dateFormatter.string(from: session.date)) - \(session.difficulty) - \(session.mode) - \(String(format: "%.0f", session.wpm)) WPM - \(String(format: "%.1f", session.accuracy))%\n"
        }
        return text
    }

    private func loadSessions() {
        // Try v2 first
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([SessionResult].self, from: data) {
            sessions = decoded
            return
        }
        // Try legacy v1
        if let data = UserDefaults.standard.data(forKey: "blind_type_sessions_v1"),
           let decoded = try? JSONDecoder().decode([SessionResult].self, from: data) {
            sessions = decoded
            persistSessions()
        }
    }

    private func persistSessions() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
}
