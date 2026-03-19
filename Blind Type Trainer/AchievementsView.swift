import SwiftUI

struct AchievementsView: View {
    @ObservedObject private var data = DataManager.shared
    @ObservedObject private var store = StoreManager.shared

    private var accent: Color { store.accentColor }
    private let baseBG = Color(red: 10/255, green: 10/255, blue: 10/255)
    private let cardBG = Color(red: 30/255, green: 30/255, blue: 30/255)

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Spacer().frame(height: 20)

                Text("Achievements")
                    .font(.system(size: 28, weight: .bold, design: .default))
                    .foregroundColor(.white)

                let achievements = data.getAchievements()
                let unlocked = achievements.filter(\.isUnlocked).count

                Text("\(unlocked) / \(achievements.count) unlocked")
                    .font(.system(size: 14, weight: .medium, design: .default))
                    .foregroundColor(accent)

                ForEach(achievements) { achievement in
                    AchievementRow(achievement: achievement, accent: accent)
                }

                Spacer().frame(height: 40)
            }
            .padding(.horizontal, 24)
        }
        .background(baseBG.ignoresSafeArea())
    }
}

struct AchievementRow: View {
    let achievement: Achievement
    let accent: Color
    private let cardBG = Color(red: 30/255, green: 30/255, blue: 30/255)

    var body: some View {
        HStack(spacing: 14) {
            // Trophy/lock indicator
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? accent.opacity(0.2) : Color.white.opacity(0.05))
                    .frame(width: 44, height: 44)
                if achievement.isUnlocked {
                    // Star shape
                    StarShape()
                        .fill(accent)
                        .frame(width: 20, height: 20)
                } else {
                    // Lock
                    LockIconSmall()
                        .frame(width: 16, height: 20)
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(achievement.title)
                    .font(.system(size: 16, weight: .bold, design: .default))
                    .foregroundColor(achievement.isUnlocked ? .white : .white.opacity(0.4))
                Text(achievement.description)
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .foregroundColor(.white.opacity(0.4))
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(cardBG)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(achievement.isUnlocked ? accent.opacity(0.3) : Color.white.opacity(0.05), lineWidth: 1)
                )
        )
        .opacity(achievement.isUnlocked ? 1.0 : 0.6)
    }
}

struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerR = min(rect.width, rect.height) / 2
        let innerR = outerR * 0.4
        for i in 0..<10 {
            let angle = (Double(i) * 36.0 - 90.0) * .pi / 180.0
            let r = i % 2 == 0 ? outerR : innerR
            let pt = CGPoint(x: center.x + CGFloat(cos(angle)) * r, y: center.y + CGFloat(sin(angle)) * r)
            if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
        }
        path.closeSubpath()
        return path
    }
}

struct LockIconSmall: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.white.opacity(0.3))
                .frame(width: 12, height: 9)
                .offset(y: 3)
            Path { path in
                path.addArc(center: CGPoint(x: 8, y: 7), radius: 5, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
            }
            .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
            .frame(width: 16, height: 12)
            .offset(y: -4)
        }
    }
}
