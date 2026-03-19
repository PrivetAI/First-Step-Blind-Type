import SwiftUI

struct KeyboardView: View {
    let difficulty: Difficulty
    var showSpace: Bool = false
    let onKeyPress: (String) -> Void
    let lastKeyCorrect: Bool?
    let lastKeyPressed: String

    @ObservedObject private var store = StoreManager.shared

    private var accent: Color { store.accentColor }
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

        let keyOpacity = difficulty.keyboardOpacity
        let outlineMode = difficulty.showOutline

        return Button(action: { onKeyPress(key) }) {
            Text(key)
                .font(.system(size: 18, weight: .medium, design: .default))
                .foregroundColor(.white.opacity(keyOpacity > 0 ? max(keyOpacity, 0.05) : 0.0))
                .frame(minWidth: 28, maxWidth: .infinity, minHeight: 42)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(outlineMode ? Color.clear : Color(red: 50/255, green: 50/255, blue: 50/255).opacity(keyOpacity))
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
        Button(action: { onKeyPress("DEL") }) {
            Text("DEL")
                .font(.system(size: 13, weight: .medium, design: .default))
                .foregroundColor(.white.opacity(difficulty.keyboardOpacity > 0 ? max(difficulty.keyboardOpacity, 0.3) : 0.0))
                .frame(width: 50, height: 42)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(red: 60/255, green: 40/255, blue: 40/255).opacity(difficulty.keyboardOpacity > 0 ? max(difficulty.keyboardOpacity, 0.1) : 0.0))
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

        return Button(action: { onKeyPress("SPACE") }) {
            Text("SPACE")
                .font(.system(size: 14, weight: .medium, design: .default))
                .foregroundColor(.white.opacity(difficulty.keyboardOpacity > 0 ? max(difficulty.keyboardOpacity, 0.3) : 0.0))
                .frame(maxWidth: .infinity, minHeight: 42)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(red: 50/255, green: 50/255, blue: 50/255).opacity(difficulty.keyboardOpacity > 0 ? max(difficulty.keyboardOpacity, 0.1) : 0.0))
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
