import SwiftUI
import WebKit

struct SettingsView: View {
    @ObservedObject private var store = StoreManager.shared
    @State private var showWebView = false
    @State private var showingPremiumModal = false

    private var accent: Color { store.accentColor }
    private let baseBG = Color(red: 10/255, green: 10/255, blue: 10/255)
    private let cardBG = Color(red: 30/255, green: 30/255, blue: 30/255)

    var body: some View {
        ZStack {
            baseBG.ignoresSafeArea()

            if showWebView {
                VStack(spacing: 0) {
                    HStack {
                        Button(action: { showWebView = false }) {
                            Text("Close")
                                .font(.system(size: 15, weight: .medium, design: .default))
                                .foregroundColor(accent)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(red: 30/255, green: 30/255, blue: 30/255))

                    SettingsWebContent(urlString: "https://example.com")
                }
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        Spacer().frame(height: 20)

                        Text("Settings")
                            .font(.system(size: 28, weight: .bold, design: .default))
                            .foregroundColor(.white)

                        // Premium section
                        VStack(spacing: 12) {
                            if store.isPremium {
                                HStack {
                                    Text("Premium Unlocked ✓")
                                        .font(.system(size: 18, weight: .bold, design: .default))
                                        .foregroundColor(accent)
                                    Spacer()
                                }
                            } else {
                                Button(action: { showingPremiumModal = true }) {
                                    HStack {
                                        Text("Upgrade to Premium")
                                            .font(.system(size: 16, weight: .bold, design: .default))
                                            .foregroundColor(.black)
                                        Spacer()
                                        Text("→")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.black)
                                    }
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(accent)
                                    )
                                }
                            }
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

                        // Theme section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Theme")
                                .font(.system(size: 18, weight: .bold, design: .default))
                                .foregroundColor(.white)

                            ForEach(store.themes, id: \.id) { theme in
                                let isSelected = store.selectedTheme == theme.id
                                let isLocked = theme.isPremium && !store.isPremium

                                Button(action: {
                                    if !isLocked {
                                        store.selectTheme(theme.id)
                                    }
                                }) {
                                    HStack(spacing: 12) {
                                        Circle()
                                            .fill(Color(red: theme.accent.0, green: theme.accent.1, blue: theme.accent.2))
                                            .frame(width: 24, height: 24)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white.opacity(isSelected ? 0.8 : 0), lineWidth: 2)
                                            )

                                        Text(theme.name)
                                            .font(.system(size: 15, weight: .medium, design: .default))
                                            .foregroundColor(isLocked ? .white.opacity(0.3) : .white)

                                        Spacer()

                                        if isLocked {
                                            Text("Premium")
                                                .font(.system(size: 11, weight: .medium, design: .default))
                                                .foregroundColor(.white.opacity(0.3))
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 6)
                                                        .fill(Color.white.opacity(0.08))
                                                )
                                        } else if isSelected {
                                            CheckmarkIcon(color: Color(red: theme.accent.0, green: theme.accent.1, blue: theme.accent.2))
                                                .frame(width: 18, height: 14)
                                        }
                                    }
                                    .padding(.vertical, 8)
                                }
                                .disabled(isLocked)
                            }
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

                        // Info section
                        VStack(spacing: 12) {
                            SettingsRow(title: "Version", value: "2.0")
                            Divider().background(Color.white.opacity(0.1))

                            Button(action: { showWebView = true }) {
                                HStack {
                                    Text("Privacy Policy")
                                        .font(.system(size: 15, weight: .medium, design: .default))
                                        .foregroundColor(.white)
                                    Spacer()
                                    ArrowRightIcon()
                                        .frame(width: 12, height: 12)
                                }
                            }

                            Divider().background(Color.white.opacity(0.1))

                            Button(action: { showWebView = true }) {
                                HStack {
                                    Text("Terms of Use")
                                        .font(.system(size: 15, weight: .medium, design: .default))
                                        .foregroundColor(.white)
                                    Spacer()
                                    ArrowRightIcon()
                                        .frame(width: 12, height: 12)
                                }
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(cardBG)
                        )

                        Spacer().frame(height: 60)
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
        .sheet(isPresented: $showingPremiumModal) {
            PremiumModalView()
        }
    }
}

struct FeatureRow: View {
    let text: String
    let included: Bool
    let accent: Color

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(included ? accent : Color.white.opacity(0.2))
                    .frame(width: 18, height: 18)
                if included {
                    CheckmarkShape()
                        .stroke(Color.black, lineWidth: 2)
                        .frame(width: 10, height: 8)
                }
            }
            Text(text)
                .font(.system(size: 14, weight: .regular, design: .default))
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX * 0.8, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        return path
    }
}

struct CheckmarkIcon: View {
    let color: Color
    var body: some View {
        CheckmarkShape()
            .stroke(color, lineWidth: 2)
    }
}

struct ArrowRightIcon: View {
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 8, y: 6))
            path.addLine(to: CGPoint(x: 0, y: 12))
        }
        .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
    }
}

struct SettingsRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 15, weight: .medium, design: .default))
                .foregroundColor(.white)
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .regular, design: .default))
                .foregroundColor(.white.opacity(0.4))
        }
    }
}

struct SettingsWebContent: UIViewRepresentable {
    let urlString: String

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = UIColor(red: 10/255, green: 10/255, blue: 10/255, alpha: 1)
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
