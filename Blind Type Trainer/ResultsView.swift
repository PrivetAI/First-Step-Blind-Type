import SwiftUI

struct ResultsView: View {
    @ObservedObject var gameManager: GameManager
    let onDismiss: () -> Void
    @ObservedObject private var store = StoreManager.shared

    private var accent: Color { store.accentColor }
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

                Button(action: shareResults) {
                    Text("Share Results")
                        .font(.system(size: 16, weight: .bold, design: .default))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(accent)
                        )
                }

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

    private func shareResults() {
        let text = "Blind Type Trainer\n\(gameManager.difficulty.rawValue) - \(gameManager.practiceMode.rawValue)\nWPM: \(String(format: "%.0f", gameManager.wpm))\nAccuracy: \(String(format: "%.1f%%", gameManager.accuracy))"
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first,
              let rootVC = window.rootViewController else { return }
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = window
            popover.sourceRect = CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 0, height: 0)
        }
        rootVC.present(activityVC, animated: true)
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
