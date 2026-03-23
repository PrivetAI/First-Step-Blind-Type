import SwiftUI

struct TrainingView: View {
    @ObservedObject var gameManager: GameManager
    let onFinish: () -> Void
    @ObservedObject private var theme = ThemeManager.shared

    private var accent: Color { theme.accentColor }
    private let baseBG = Color(red: 10/255, green: 10/255, blue: 10/255)

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button(action: {
                        gameManager.endSession()
                        onFinish()
                    }) {
                        Text("Quit")
                            .font(.system(size: 15, weight: .medium, design: .default))
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(red: 30/255, green: 30/255, blue: 30/255))
                            )
                    }

                    Spacer()

                    Text("\(gameManager.timeRemaining)s")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(gameManager.timeRemaining <= 10 ? Color.red : accent)

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(String(format: "%.0f", gameManager.wpm)) WPM")
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.7))
                        Text("\(gameManager.wordsCompleted) words")
                            .font(.system(size: 12, weight: .regular, design: .default))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                // Mode indicator
                Text(gameManager.practiceMode.rawValue)
                    .font(.system(size: 12, weight: .medium, design: .default))
                    .foregroundColor(accent.opacity(0.6))
                    .padding(.top, 4)

                Spacer()

                // Current text display
                VStack(spacing: 12) {
                    if gameManager.practiceMode == .words {
                        Text(gameManager.currentText)
                            .font(.system(size: 40, weight: .bold, design: .default))
                            .foregroundColor(.white)
                            .shadow(color: accent.opacity(0.3), radius: 10)
                    } else {
                        // For sentences, show with wrapping
                        Text(gameManager.currentText)
                            .font(.system(size: 22, weight: .bold, design: .default))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .shadow(color: accent.opacity(0.3), radius: 10)
                            .padding(.horizontal, 20)
                    }

                    // Typed progress - show what user actually typed
                    typedProgressView
                        .padding(.horizontal, 20)
                }

                Spacer()

                // Keyboard
                KeyboardView(
                    difficulty: gameManager.difficulty,
                    showSpace: gameManager.practiceMode != .words,
                    onKeyPress: { key in
                        gameManager.handleKeyPress(key)
                    },
                    lastKeyCorrect: gameManager.lastKeyCorrect,
                    lastKeyPressed: gameManager.lastKeyPressed
                )
                .padding(.bottom, geo.safeAreaInsets.bottom > 0 ? 0 : 8)
            }
        }
        .background(baseBG.ignoresSafeArea())
        .onChange(of: gameManager.isFinished) { finished in
            if finished { onFinish() }
        }
    }

    @ViewBuilder
    private var typedProgressView: some View {
        let fontSize: CGFloat = gameManager.practiceMode == .words ? 22 : 16
        if gameManager.practiceMode == .words {
            // Words mode: horizontal scroll is fine
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 1) {
                    ForEach(Array(gameManager.currentText.enumerated()), id: \.offset) { index, char in
                        charView(index: index, char: char, fontSize: fontSize)
                    }
                }
            }
        } else {
            // Sentences mode: wrap text using a single attributed-style Text
            let chars = Array(gameManager.currentText)
            let typedChars = Array(gameManager.typedText)
            chars.indices.reduce(Text("")) { result, index in
                let ch = index < typedChars.count ? String(typedChars[index]) : String(chars[index])
                let color = colorForChar(at: index)
                return result + Text(ch)
                    .font(.system(size: fontSize, weight: .medium, design: .monospaced))
                    .foregroundColor(color)
            }
            .multilineTextAlignment(.center)
        }
    }

    private func charView(index: Int, char: Character, fontSize: CGFloat) -> some View {
        let typedChars = Array(gameManager.typedText)
        let display = index < typedChars.count ? String(typedChars[index]) : String(char)
        return Text(display)
            .font(.system(size: fontSize, weight: .medium, design: .monospaced))
            .foregroundColor(colorForChar(at: index))
    }

    private func colorForChar(at index: Int) -> Color {
        let typed = Array(gameManager.typedText)
        let text = Array(gameManager.currentText.lowercased())
        if index < typed.count {
            if index < text.count && typed[index] == text[index] {
                return accent
            } else {
                return .red
            }
        } else if index == typed.count {
            return .white
        }
        return .white.opacity(0.3)
    }
}
