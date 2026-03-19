import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @ObservedObject private var store = StoreManager.shared

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(red: 10/255, green: 10/255, blue: 10/255)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Group {
                    switch selectedTab {
                    case 0:
                        HomeView()
                    case 1:
                        StatsView()
                    case 2:
                        SessionHistoryView()
                    case 3:
                        AchievementsView()
                    case 4:
                        SettingsView()
                    default:
                        HomeView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                CustomTabBar(selectedTab: $selectedTab)
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @ObservedObject private var store = StoreManager.shared

    private var accent: Color { store.accentColor }
    private let tabs = ["Train", "Stats", "History", "Awards", "Settings"]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<5, id: \.self) { index in
                Button(action: { selectedTab = index }) {
                    VStack(spacing: 4) {
                        TabIconView(index: index, isSelected: selectedTab == index)
                            .frame(width: 24, height: 24)

                        Text(tabs[index])
                            .font(.system(size: 10, weight: .medium, design: .default))
                            .foregroundColor(selectedTab == index ? accent : .white.opacity(0.4))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
        }
        .background(Color(red: 30/255, green: 30/255, blue: 30/255))
    }
}

struct TabIconView: View {
    let index: Int
    let isSelected: Bool
    @ObservedObject private var store = StoreManager.shared

    private var accent: Color { store.accentColor }
    private var iconColor: Color { isSelected ? accent : .white.opacity(0.4) }

    var body: some View {
        switch index {
        case 0:
            TrainTabIcon(color: iconColor)
        case 1:
            ChartTabIcon(color: iconColor)
        case 2:
            HistoryTabIcon(color: iconColor)
        case 3:
            TrophyTabIcon(color: iconColor)
        default:
            GearTabIcon(color: iconColor)
        }
    }
}

struct TrainTabIcon: View {
    let color: Color
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .stroke(color, lineWidth: 1.5)
                .frame(width: 20, height: 16)
            VStack(spacing: 2) {
                HStack(spacing: 2) {
                    ForEach(0..<4, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 1)
                            .fill(color)
                            .frame(width: 3, height: 3)
                    }
                }
                HStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 1)
                            .fill(color)
                            .frame(width: 3, height: 3)
                    }
                }
            }
        }
    }
}

struct ChartTabIcon: View {
    let color: Color
    var body: some View {
        HStack(alignment: .bottom, spacing: 3) {
            RoundedRectangle(cornerRadius: 1)
                .fill(color)
                .frame(width: 4, height: 8)
            RoundedRectangle(cornerRadius: 1)
                .fill(color)
                .frame(width: 4, height: 16)
            RoundedRectangle(cornerRadius: 1)
                .fill(color)
                .frame(width: 4, height: 12)
            RoundedRectangle(cornerRadius: 1)
                .fill(color)
                .frame(width: 4, height: 20)
        }
    }
}

struct HistoryTabIcon: View {
    let color: Color
    var body: some View {
        VStack(spacing: 3) {
            ForEach(0..<3, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 1)
                    .fill(color)
                    .frame(width: 18, height: 4)
            }
        }
    }
}

struct TrophyTabIcon: View {
    let color: Color
    var body: some View {
        ZStack {
            // Cup body
            Path { path in
                path.move(to: CGPoint(x: 6, y: 4))
                path.addLine(to: CGPoint(x: 18, y: 4))
                path.addLine(to: CGPoint(x: 16, y: 14))
                path.addLine(to: CGPoint(x: 8, y: 14))
                path.closeSubpath()
            }
            .stroke(color, lineWidth: 1.5)
            // Stem
            Path { path in
                path.move(to: CGPoint(x: 12, y: 14))
                path.addLine(to: CGPoint(x: 12, y: 18))
            }
            .stroke(color, lineWidth: 1.5)
            // Base
            Path { path in
                path.move(to: CGPoint(x: 8, y: 18))
                path.addLine(to: CGPoint(x: 16, y: 18))
            }
            .stroke(color, lineWidth: 1.5)
        }
    }
}

struct GearTabIcon: View {
    let color: Color
    var body: some View {
        ZStack {
            Circle()
                .stroke(color, lineWidth: 1.5)
                .frame(width: 10, height: 10)
            ForEach(0..<6, id: \.self) { i in
                RoundedRectangle(cornerRadius: 1)
                    .fill(color)
                    .frame(width: 3, height: 6)
                    .offset(y: -10)
                    .rotationEffect(.degrees(Double(i) * 60))
            }
        }
    }
}
