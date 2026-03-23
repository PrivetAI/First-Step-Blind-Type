import SwiftUI

struct ResultsView: View {
    @ObservedObject var gameManager: GameManager
    let onDismiss: () -> Void
    @ObservedObject private var theme = ThemeManager.shared

    private var accent: Color { theme.accentColor }
    private let baseBG = Color(red: 10/255, green: 10/255, blue: 10/255)
    private let cardBG = Color(red: 30/255, green: 30/255, blue: 30/255)

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer().frame(height: 40)

                Text("Session Complete")
                    .font(.system(size: 28, weight: .bold, design: .default))
                    .foregroundColor(.white)

                HStack(spacing: 8) {
                    Text(gameManager.difficulty.rawValue)
                        .font(.system(size: 16, weight: .medium, design: .default))
                        .foregroundColor(accent)
                    Text("--")
                        .foregroundColor(.white.opacity(0.3))
                    Text(gameManager.practiceMode.rawValue)
                        .font(.system(size: 16, weight: .medium, design: .default))
                        .foregroundColor(accent.opacity(0.7))
                }

                StatCard(title: "Words Per Minute", value: String(format: "%.0f", gameManager.wpm), accent: accent)
                StatCard(title: "Accuracy", value: String(format: "%.1f%%", gameManager.accuracy), accent: accent)
                StatCard(title: "Words Completed", value: "\(gameManager.wordsCompleted)", accent: accent)

                Button(action: onDismiss) {
                    Text("Back to Menu")
                        .font(.system(size: 16, weight: .medium, design: .default))
                        .foregroundColor(.white.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                }

                Spacer().frame(height: 20)
            }
            .padding(.horizontal, 24)
        }
        .background(baseBG.ignoresSafeArea())
    }

}

struct StatCard: View {
    let title: String
    let value: String
    let accent: Color
    private let cardBG = Color(red: 30/255, green: 30/255, blue: 30/255)

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .default))
                .foregroundColor(.white.opacity(0.5))

            Text(value)
                .font(.system(size: 36, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardBG)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(accent.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: accent.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
}
