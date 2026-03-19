import Foundation
import StoreKit

class StoreManager: ObservableObject {
    static let shared = StoreManager()
    static let premiumProductID = "com.blindtype.trainer.premium"

    @Published var isPremium: Bool = false
    @Published var premiumProduct: SKProduct?
    @Published var isPurchasing = false
    @Published var selectedTheme: String = "default"

    private let premiumKey = "blind_type_premium_unlocked"
    private let themeKey = "blind_type_selected_theme"

    let themes: [(id: String, name: String, accent: (Double, Double, Double), isPremium: Bool)] = [
        ("default", "Neon Green", (0, 230.0/255.0, 118.0/255.0), false),
        ("cyan", "Cyber Cyan", (0, 210.0/255.0, 255.0/255.0), true),
        ("purple", "Electric Purple", (180.0/255.0, 80.0/255.0, 255.0/255.0), true),
        ("orange", "Amber Glow", (255.0/255.0, 170.0/255.0, 0), true),
    ]

    init() {
        isPremium = UserDefaults.standard.bool(forKey: premiumKey)
        selectedTheme = UserDefaults.standard.string(forKey: themeKey) ?? "default"
    }

    var accentColor: Color {
        guard let theme = themes.first(where: { $0.id == selectedTheme }) else {
            return Color(red: 0, green: 230.0/255.0, blue: 118.0/255.0)
        }
        return Color(red: theme.accent.0, green: theme.accent.1, blue: theme.accent.2)
    }

    func selectTheme(_ id: String) {
        selectedTheme = id
        UserDefaults.standard.set(id, forKey: themeKey)
    }

    func purchasePremium() {
        isPurchasing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.unlockPremium()
            self?.isPurchasing = false
        }
    }

    func restorePurchases() {
        isPurchasing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.isPurchasing = false
        }
    }

    func unlockPremium() {
        isPremium = true
        UserDefaults.standard.set(true, forKey: premiumKey)
    }
}

import SwiftUI
