import Foundation
import SwiftUI

enum Difficulty: String, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case expert = "Expert"

    var keyboardOpacity: Double {
        switch self {
        case .easy: return 1.0
        case .medium: return 0.5
        case .hard: return 0.2
        case .expert: return 0.0
        }
    }

    var showOutline: Bool {
        self == .expert
    }
}

class GameManager: ObservableObject {
    @Published var currentText = ""
    @Published var typedText = ""
    @Published var timeRemaining = 60
    @Published var isActive = false
    @Published var isFinished = false
    @Published var lastKeyCorrect: Bool? = nil
    @Published var lastKeyPressed: String = ""
    @Published var correctChars = 0
    @Published var totalChars = 0
    @Published var wordsCompleted = 0

    var difficulty: Difficulty = .easy
    var practiceMode: PracticeMode = .words
    private var textQueue: [String] = []
    private var timer: Timer?
    private var startTime: Date?
    private var sessionStartTime: Date?

    var wpm: Double {
        guard wordsCompleted > 0 else { return 0 }
        let elapsed = 60.0 - Double(timeRemaining)
        guard elapsed > 0 else { return 0 }
        return Double(wordsCompleted) / (elapsed / 60.0)
    }

    var accuracy: Double {
        guard totalChars > 0 else { return 100 }
        return (Double(correctChars) / Double(totalChars)) * 100
    }

    var sessionDuration: Int {
        guard let start = sessionStartTime else { return 0 }
        return Int(Date().timeIntervalSince(start))
    }

    func startSession(difficulty: Difficulty, mode: PracticeMode) {
        self.difficulty = difficulty
        self.practiceMode = mode

        switch mode {
        case .words:
            textQueue = WordBank.wordsForSession(count: 100)
        case .sentences:
            textQueue = WordBank.sentencesForSession(count: 50)
        case .mixed:
            textQueue = WordBank.mixedForSession(count: 80)
        }

        wordsCompleted = 0
        correctChars = 0
        totalChars = 0
        typedText = ""
        timeRemaining = 60
        isActive = true
        isFinished = false
        sessionStartTime = Date()
        nextText()
        startTimer()
    }

    func handleKeyPress(_ key: String) {
        guard isActive else { return }

        if key == "DEL" {
            if !typedText.isEmpty {
                typedText.removeLast()
            }
            return
        }

        let inputChar = key == "SPACE" ? " " : key.lowercased()
        let expectedIndex = typedText.count
        let textChars = Array(currentText)

        totalChars += 1

        if expectedIndex < textChars.count {
            let expected = String(textChars[expectedIndex]).lowercased()
            if inputChar == expected {
                correctChars += 1
                lastKeyCorrect = true
            } else {
                lastKeyCorrect = false
            }
        } else {
            lastKeyCorrect = false
        }

        lastKeyPressed = key
        typedText += inputChar

        if typedText.count >= currentText.count {
            if typedText == currentText.lowercased() {
                wordsCompleted += max(1, currentText.components(separatedBy: " ").count)
            } else {
                wordsCompleted += 1
            }
            typedText = ""
            nextText()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.lastKeyCorrect = nil
            self.lastKeyPressed = ""
        }
    }

    func endSession() {
        isActive = false
        isFinished = true
        timer?.invalidate()
        timer = nil

        let elapsed = sessionDuration
        let result = SessionResult(
            wpm: wpm,
            accuracy: accuracy,
            difficulty: difficulty.rawValue,
            wordsTyped: wordsCompleted,
            mode: practiceMode.rawValue,
            durationSeconds: max(elapsed, 60 - timeRemaining)
        )
        DataManager.shared.saveSession(result)
    }

    private func nextText() {
        if textQueue.isEmpty {
            switch practiceMode {
            case .words: textQueue = WordBank.wordsForSession(count: 100)
            case .sentences: textQueue = WordBank.sentencesForSession(count: 50)
            case .mixed: textQueue = WordBank.mixedForSession(count: 80)
            }
        }
        currentText = textQueue.removeFirst()
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.endSession()
            }
        }
    }
}
