import SwiftUI

struct KeyboardView: View {
    let difficulty: Difficulty
    var showSpace: Bool = false
    let onKeyPress: (String) -> Void
    let lastKeyCorrect: Bool?
    let lastKeyPressed: String

    @ObservedObject private var theme = ThemeManager.shared
    @State private var hiddenKeys: Set<String> = []

    private var accent: Color { theme.accentColor }
    private let errorRed = Color(red: 1, green: 0.2, blue: 0.2)

    private let row1 = ["Q","W","E","R","T","Y","U","I","O","P"]
    private let row2 = ["A","S","D","F","G","H","J","K","L"]
    private let row3 = ["Z","X","C","V","B","N","M"]

    var body: some View {
        VStack(spacing: 8) {
            keyRow(row1)
            keyRow(row2)
            HStack(spacing: 5) {
                Spacer().frame(width: 10)
                ForEach(row3, id: \.self) { key in
                    keyButton(key)
                }
                deleteButton
                Spacer().frame(width: 10)
            }
            if showSpace {
                spaceButton
            }
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 8)
        .onAppear {
            generateHiddenKeys()
        }
        .onChange(of: difficulty) { _ in
            generateHiddenKeys()
        }
    }
    
    private func generateHiddenKeys() {
        let allKeys = row1 + row2 + row3
        let percentage = difficulty.hiddenPercentage
        let hideCount = Int(Double(allKeys.count) * percentage)
        
        // Randomly select keys to hide
        let shuffled = allKeys.shuffled()
        hiddenKeys = Set(shuffled.prefix(hideCount))
    }

    private func keyRow(_ keys: [String]) -> some View {
        HStack(spacing: 5) {
            ForEach(keys, id: \.self) { key in
                keyButton(key)
            }
        }
    }

    private func keyButton(_ key: String) -> some View {
        let isLastPressed = lastKeyPressed.uppercased() == key && lastKeyCorrect != nil
        let glowColor: Color = {
            guard isLastPressed, let correct = lastKeyCorrect else { return .clear }
            return correct ? accent : errorRed
        }()

        let isHidden = hiddenKeys.contains(key)
        let outlineMode = difficulty.showOutline

        return Button(action: { onKeyPress(key) }) {
            Text(isHidden ? "" : key)
                .font(.system(size: 18, weight: .medium, design: .default))
                .foregroundColor(.white)
                .frame(minWidth: 28, maxWidth: .infinity, minHeight: 42)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(outlineMode ? Color.clear : Color(red: 50/255, green: 50/255, blue: 50/255))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(
                                    outlineMode ? Color.white.opacity(0.08) : Color.clear,
                                    lineWidth: 1
                                )
                        )
                )
                .shadow(color: glowColor.opacity(0.8), radius: isLastPressed ? 10 : 0)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(glowColor, lineWidth: isLastPressed ? 2 : 0)
                )
        }
    }

    private var deleteButton: some View {
        let isHidden = difficulty == .expert
        
        return Button(action: { onKeyPress("DEL") }) {
            Text(isHidden ? "" : "DEL")
                .font(.system(size: 13, weight: .medium, design: .default))
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 50, height: 42)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(red: 60/255, green: 40/255, blue: 40/255))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(
                                    difficulty.showOutline ? Color.white.opacity(0.08) : Color.clear,
                                    lineWidth: 1
                                )
                        )
                )
        }
    }

    private var spaceButton: some View {
        let isLastPressed = lastKeyPressed == "SPACE" && lastKeyCorrect != nil
        let glowColor: Color = {
            guard isLastPressed, let correct = lastKeyCorrect else { return .clear }
            return correct ? accent : errorRed
        }()
        
        let isHidden = difficulty == .expert

        return Button(action: { onKeyPress("SPACE") }) {
            Text(isHidden ? "" : "SPACE")
                .font(.system(size: 14, weight: .medium, design: .default))
                .foregroundColor(.white.opacity(0.7))
                .frame(maxWidth: .infinity, minHeight: 42)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(red: 50/255, green: 50/255, blue: 50/255))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(
                                    difficulty.showOutline ? Color.white.opacity(0.08) : Color.clear,
                                    lineWidth: 1
                                )
                        )
                )
                .shadow(color: glowColor.opacity(0.8), radius: isLastPressed ? 10 : 0)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(glowColor, lineWidth: isLastPressed ? 2 : 0)
                )
        }
        .padding(.horizontal, 20)
    }
}
