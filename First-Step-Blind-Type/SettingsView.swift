import SwiftUI
import WebKit

struct SettingsView: View {
    @ObservedObject private var theme = ThemeManager.shared
    @State private var showPrivacyPolicy = false

    private var accent: Color { theme.accentColor }
    private let baseBG = Color(red: 10/255, green: 10/255, blue: 10/255)
    private let cardBG = Color(red: 30/255, green: 30/255, blue: 30/255)

    var body: some View {
        ZStack {
            baseBG.ignoresSafeArea()

            ScrollView {
                    VStack(spacing: 20) {
                        Spacer().frame(height: 20)

                        Text("Settings")
                            .font(.system(size: 28, weight: .bold, design: .default))
                            .foregroundColor(.white)

                        // Theme section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Theme")
                                .font(.system(size: 18, weight: .bold, design: .default))
                                .foregroundColor(.white)

                            ForEach(theme.themes, id: \.id) { themeOption in
                                let isSelected = theme.selectedTheme == themeOption.id

                                Button(action: {
                                    theme.selectTheme(themeOption.id)
                                }) {
                                    HStack(spacing: 12) {
                                        Circle()
                                            .fill(Color(red: themeOption.accent.0, green: themeOption.accent.1, blue: themeOption.accent.2))
                                            .frame(width: 24, height: 24)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white.opacity(isSelected ? 0.8 : 0), lineWidth: 2)
                                            )

                                        Text(themeOption.name)
                                            .font(.system(size: 15, weight: .medium, design: .default))
                                            .foregroundColor(.white)

                                        Spacer()

                                        if isSelected {
                                            CheckmarkIcon(color: Color(red: themeOption.accent.0, green: themeOption.accent.1, blue: themeOption.accent.2))
                                                .frame(width: 18, height: 14)
                                        }
                                    }
                                    .padding(.vertical, 8)
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

                        // Info section
                        VStack(spacing: 12) {
                            SettingsRow(title: "Version", value: "2.0")
                            
                            Divider().background(Color.white.opacity(0.1))
                            
                            Button(action: {
                                showPrivacyPolicy = true
                            }) {
                                HStack {
                                    Text("Privacy Policy")
                                        .font(.system(size: 15, weight: .medium, design: .default))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("→")
                                        .foregroundColor(.white.opacity(0.4))
                                }
                            }
                            .sheet(isPresented: $showPrivacyPolicy) {
                                PrivacyPolicyWebView(url: URL(string: "http://firststepblindtype.org/click.php")!)
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

struct PrivacyPolicyWebView: View {
    let url: URL
    @Environment(\.presentationMode) var presentationMode
    
    private let baseBG = Color(red: 10/255, green: 10/255, blue: 10/255)
    
    var body: some View {
        NavigationView {
            PrivacyWebViewRepresentable(url: url)
                .background(baseBG.ignoresSafeArea())
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(.white)
                    }
                }
        }
        .preferredColorScheme(.dark)
    }
}

struct PrivacyWebViewRepresentable: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
