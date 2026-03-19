import SwiftUI

struct HomeView: View {
    @StateObject private var gameManager = GameManager()
    @ObservedObject private var store = StoreManager.shared
    @State private var showTraining = false
    @State private var showResults = false
    @State private var selectedMode: PracticeMode = .words
    @State private var selectedDifficulty: Difficulty = .easy

    private var accent: Color { store.accentColor }
    private let baseBG = Color(red: 10/255, green: 10/255, blue: 10/255)
    private let cardBG = Color(red: 30/255, green: 30/255, blue: 30/255)

    var body: some View {
        NavigationView {
            ZStack {
                baseBG.ignoresSafeArea()

                if showTraining {
                    TrainingView(gameManager: gameManager, onFinish: {
                        showTraining = false
                        showResults = true
                    })
                } else if showResults {
                    ResultsView(gameManager: gameManager, onDismiss: {
                        showResults = false
                    })
                } else {
                    mainMenu
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    var mainMenu: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer().frame(height: 40)

                Text("Blind Type")
                    .font(.system(size: 36, weight: .bold, design: .default))
                    .foregroundColor(.white)

                Text("Trainer")
                    .font(.system(size: 20, weight: .light, design: .default))
                    .foregroundColor(accent)

                Spacer().frame(height: 12)

                // Practice Mode selector
                VStack(alignment: .leading, spacing: 10) {
                    Text("Practice Mode")
                        .font(.system(size: 14, weight: .medium, design: .default))
                        .foregroundColor(.white.opacity(0.5))

                    HStack(spacing: 8) {
                        ForEach(PracticeMode.allCases, id: \.rawValue) { mode in
                            Button(action: { selectedMode = mode }) {
                                Text(mode.rawValue)
                                    .font(.system(size: 14, weight: .bold, design: .default))
                                    .foregroundColor(selectedMode == mode ? .black : .white.opacity(0.6))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(selectedMode == mode ? accent : cardBG)
                                    )
                            }
                        }
                    }
                }

                Spacer().frame(height: 8)

                Text("Select Difficulty")
                    .font(.system(size: 14, weight: .medium, design: .default))
                    .foregroundColor(.white.opacity(0.5))

                ForEach(Difficulty.allCases, id: \.rawValue) { difficulty in
                    DifficultyButton(
                        difficulty: difficulty,
                        accent: accent,
                        action: {
                            selectedDifficulty = difficulty
                            gameManager.startSession(difficulty: difficulty, mode: selectedMode)
                            showTraining = true
                        }
                    )
                }

                Spacer().frame(height: 20)
            }
            .padding(.horizontal, 24)
        }
    }
}

struct DifficultyButton: View {
    let difficulty: Difficulty
    let accent: Color
    let action: () -> Void

    private let cardBG = Color(red: 30/255, green: 30/255, blue: 30/255)

    private var subtitle: String {
        switch difficulty {
        case .easy: return "Full keyboard visible"
        case .medium: return "50% opacity keyboard"
        case .hard: return "20% opacity keyboard"
        case .expert: return "Invisible keyboard"
        }
    }

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(difficulty.rawValue)
                        .font(.system(size: 20, weight: .bold, design: .default))
                        .foregroundColor(.white)

                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular, design: .default))
                        .foregroundColor(.white.opacity(0.5))
                }

                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(cardBG)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(accent.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: accent.opacity(0.15), radius: 8, x: 0, y: 2)
            )
        }
    }
}
