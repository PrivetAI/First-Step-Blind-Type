import SwiftUI

struct SessionHistoryView: View {
    @ObservedObject private var data = DataManager.shared
    @ObservedObject private var store = StoreManager.shared

    private var accent: Color { store.accentColor }
    private let baseBG = Color(red: 10/255, green: 10/255, blue: 10/255)
    private let cardBG = Color(red: 30/255, green: 30/255, blue: 30/255)

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Spacer().frame(height: 20)

                Text("Session History")
                    .font(.system(size: 28, weight: .bold, design: .default))
                    .foregroundColor(.white)

                Text("Last 50 sessions")
                    .font(.system(size: 14, weight: .regular, design: .default))
                    .foregroundColor(.white.opacity(0.4))

                if data.last50Sessions.isEmpty {
                    VStack(spacing: 12) {
                        Text("No sessions yet")
                            .font(.system(size: 18, weight: .medium, design: .default))
                            .foregroundColor(.white.opacity(0.4))
                        Text("Complete a training session to see your history here")
                            .font(.system(size: 14, weight: .regular, design: .default))
                            .foregroundColor(.white.opacity(0.3))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 60)
                } else {
                    ForEach(data.last50Sessions) { session in
                        SessionRow(session: session, accent: accent)
                    }
                }

                Spacer().frame(height: 40)
            }
            .padding(.horizontal, 24)
        }
        .background(baseBG.ignoresSafeArea())
    }
}

struct SessionRow: View {
    let session: SessionResult
    let accent: Color
    private let cardBG = Color(red: 30/255, green: 30/255, blue: 30/255)

    private var dateString: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d, h:mm a"
        return fmt.string(from: session.date)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(dateString)
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .foregroundColor(.white.opacity(0.5))
                HStack(spacing: 6) {
                    Text(session.difficulty)
                        .font(.system(size: 14, weight: .bold, design: .default))
                        .foregroundColor(.white)
                    Text(session.mode)
                        .font(.system(size: 12, weight: .medium, design: .default))
                        .foregroundColor(accent.opacity(0.7))
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(String(format: "%.0f", session.wpm)) WPM")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                Text("\(String(format: "%.1f", session.accuracy))%")
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundColor(session.accuracy >= 90 ? accent : .white.opacity(0.5))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(cardBG)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(accent.opacity(0.1), lineWidth: 1)
                )
        )
    }
}
