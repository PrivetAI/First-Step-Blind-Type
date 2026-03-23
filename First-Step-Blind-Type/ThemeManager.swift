import SwiftUI

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var selectedTheme: String = "neon"
    
    let themes: [(id: String, name: String, accent: (Double, Double, Double))] = [
        ("neon", "Neon Purple", (0.8, 0.4, 1.0)),
        ("cyan", "Cyan", (0.0, 0.8, 1.0)),
        ("green", "Green", (0.0, 1.0, 0.6)),
        ("orange", "Orange", (1.0, 0.6, 0.0)),
        ("pink", "Pink", (1.0, 0.3, 0.7)),
        ("blue", "Blue", (0.3, 0.6, 1.0))
    ]
    
    var accentColor: Color {
        if let theme = themes.first(where: { $0.id == selectedTheme }) {
            return Color(red: theme.accent.0, green: theme.accent.1, blue: theme.accent.2)
        }
        return Color(red: 0.8, green: 0.4, blue: 1.0)
    }
    
    init() {
        if let saved = UserDefaults.standard.string(forKey: "selectedTheme") {
            selectedTheme = saved
        }
    }
    
    func selectTheme(_ id: String) {
        selectedTheme = id
        UserDefaults.standard.set(id, forKey: "selectedTheme")
    }
}
