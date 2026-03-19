import SwiftUI

struct StatsView: View {
    @ObservedObject private var data = DataManager.shared
    @ObservedObject private var store = StoreManager.shared

    private var accent: Color { store.accentColor }
    private let baseBG = Color(red: 10/255, green: 10/255, blue: 10/255)
    private let cardBG = Color(red: 30/255, green: 30/255, blue: 30/255)

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer().frame(height: 20)

                Text("Statistics")
                    .font(.system(size: 28, weight: .bold, design: .default))
                    .foregroundColor(.white)

                // Time tracking cards
                VStack(alignment: .leading, spacing: 12) {
                    Text("Practice Time")
                        .font(.system(size: 16, weight: .medium, design: .default))
                        .foregroundColor(.white.opacity(0.7))

                    HStack(spacing: 10) {
                        TimeCard(label: "Today", value: data.formatTime(data.practiceTimeToday()), accent: accent)
                        TimeCard(label: "This Week", value: data.formatTime(data.practiceTimeThisWeek()), accent: accent)
                    }
                    HStack(spacing: 10) {
                        TimeCard(label: "This Month", value: data.formatTime(data.practiceTimeThisMonth()), accent: accent)
                        TimeCard(label: "Total", value: data.formatTime(data.totalPracticeTime()), accent: accent)
                    }
                }

                // Summary cards
                HStack(spacing: 12) {
                    MiniStatCard(title: "Best WPM", value: String(format: "%.0f", data.bestWPM), color: accent)
                    MiniStatCard(title: "Sessions", value: "\(data.totalSessions)", color: accent)
                    MiniStatCard(title: "Avg Acc", value: String(format: "%.0f%%", data.averageAccuracy), color: accent)
                }

                // WPM Chart
                VStack(alignment: .leading, spacing: 12) {
                    Text("WPM Over Time")
                        .font(.system(size: 16, weight: .medium, design: .default))
                        .foregroundColor(.white.opacity(0.7))

                    LineChartView(dataPoints: data.recentWPMs, lineColor: accent)
                        .frame(height: 200)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(cardBG)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(accent.opacity(0.15), lineWidth: 1)
                        )
                )

                // Accuracy Chart
                VStack(alignment: .leading, spacing: 12) {
                    Text("Accuracy Trend")
                        .font(.system(size: 16, weight: .medium, design: .default))
                        .foregroundColor(.white.opacity(0.7))

                    LineChartView(dataPoints: data.recentAccuracies, lineColor: accent.opacity(0.8))
                        .frame(height: 160)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(cardBG)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(accent.opacity(0.15), lineWidth: 1)
                        )
                )

                // Export button (premium only)
                if store.isPremium {
                    Button(action: exportStats) {
                        Text("Export Stats")
                            .font(.system(size: 15, weight: .bold, design: .default))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(accent)
                            )
                    }
                }

                Spacer().frame(height: 40)
            }
            .padding(.horizontal, 24)
        }
        .background(baseBG.ignoresSafeArea())
    }

    private func exportStats() {
        let text = data.exportStatsText()
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

struct TimeCard: View {
    let label: String
    let value: String
    let accent: Color
    private let cardBG = Color(red: 30/255, green: 30/255, blue: 30/255)

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .default))
                .foregroundColor(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(cardBG)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(accent.opacity(0.15), lineWidth: 1)
                )
        )
    }
}

struct MiniStatCard: View {
    let title: String
    let value: String
    let color: Color
    private let cardBG = Color(red: 30/255, green: 30/255, blue: 30/255)

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            Text(title)
                .font(.system(size: 11, weight: .medium, design: .default))
                .foregroundColor(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(cardBG)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.15), lineWidth: 1)
                )
        )
    }
}
