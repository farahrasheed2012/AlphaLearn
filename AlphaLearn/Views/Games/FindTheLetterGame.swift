import SwiftUI

// MARK: - Find The Letter Game

/// The app shows a target letter and the child must find it among a grid of options.
/// Includes audio pronunciation of the target letter.
struct FindTheLetterGame: View {
    @EnvironmentObject var progress: ProgressModel
    @Environment(\.dismiss) var dismiss

    @State private var targetLetter: LetterItem = AlphabetData.letters[0]
    @State private var options: [LetterItem] = []
    @State private var score = 0
    @State private var round = 1
    @State private var totalRounds = 8
    @State private var showConfetti = false
    @State private var showComplete = false
    @State private var correctTapped: String?
    @State private var wrongTapped: String?
    @State private var message = ""

    private let audio = AudioService.shared
    private let gridSize = 9 // 3x3 grid

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 20) {
                // Round progress
                HStack {
                    ForEach(0..<totalRounds, id: \.self) { i in
                        Circle()
                            .fill(i < round ? Color.green : Color.gray.opacity(0.3))
                            .frame(width: 12, height: 12)
                    }
                }
                .padding(.top)

                // Target letter prompt
                VStack(spacing: 8) {
                    Text("Find the letter:")
                        .font(.title3)
                        .foregroundColor(.secondary)

                    HStack(spacing: 12) {
                        Text(targetLetter.uppercase)
                            .font(.system(size: 60, weight: .bold, design: .rounded))
                            .foregroundColor(targetLetter.color)

                        Button {
                            audio.speakLetter(targetLetter.uppercase)
                        } label: {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.title2)
                                .foregroundColor(targetLetter.color)
                        }
                    }
                }

                // Feedback
                Text(message)
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .frame(height: 30)

                // Letter grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                    ForEach(options) { letter in
                        gridButton(letter)
                    }
                }
                .padding(.horizontal, 30)

                Spacer()

                // Score
                HStack {
                    Text("⭐ \(score)")
                        .font(.title3.bold())
                    Spacer()
                    Text("Round \(round)/\(totalRounds)")
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 30)
                .padding(.bottom)
            }

            ConfettiView(isActive: $showConfetti)

            if showComplete { completionOverlay }
        }
        .navigationTitle("Find the Letter")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setupRound()
            audio.speakInstruction("Find the letter!")
        }
    }

    // MARK: - Grid Button

    private func gridButton(_ letter: LetterItem) -> some View {
        Button {
            tapped(letter)
        } label: {
            Text(letter.uppercase)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 80)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(backgroundColor(for: letter))
                )
                .shadow(radius: 2)
        }
        .disabled(correctTapped != nil)
    }

    private func backgroundColor(for letter: LetterItem) -> AnyShapeStyle {
        if correctTapped == letter.id {
            return AnyShapeStyle(Color.green.gradient)
        } else if wrongTapped == letter.id {
            return AnyShapeStyle(Color.red.gradient)
        } else {
            return AnyShapeStyle(letter.color.gradient)
        }
    }

    // MARK: - Logic

    private func setupRound() {
        // Pick a target
        targetLetter = AlphabetData.letters.randomElement()!

        // Build options: include target + random others
        var opts = Set<String>([targetLetter.id])
        while opts.count < gridSize {
            if let random = AlphabetData.letters.randomElement() {
                opts.insert(random.id)
            }
        }
        options = opts.compactMap { id in AlphabetData.letters.first { $0.id == id } }.shuffled()

        correctTapped = nil
        wrongTapped = nil
        message = ""

        // Speak the target
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            audio.speakLetter(targetLetter.uppercase)
        }
    }

    private func tapped(_ letter: LetterItem) {
        if letter.id == targetLetter.id {
            // Correct!
            correctTapped = letter.id
            score += 1
            message = CheerMessages.randomSuccess()
            audio.playSuccess()
            audio.hapticSuccess()

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if round < totalRounds {
                    round += 1
                    setupRound()
                } else {
                    finishGame()
                }
            }
        } else {
            // Wrong
            wrongTapped = letter.id
            message = CheerMessages.randomEncouragement()
            audio.playTryAgain()
            audio.hapticError()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                wrongTapped = nil
            }
        }
    }

    private func finishGame() {
        showConfetti = true
        showComplete = true
        progress.recordGameCompletion(gameType: .findLetter, stars: score)
        ProgressStore.shared.save(progress)
        audio.playCelebration()
    }

    // MARK: - Completion

    private var completionOverlay: some View {
        VStack(spacing: 20) {
            Text("🎉").font(.system(size: 80))
            Text("Amazing!").font(.largeTitle.bold())
            Text("You found \(score) out of \(totalRounds) letters!")
                .font(.title3)

            KidButton(title: "Play Again", emoji: "🔄", color: .green) {
                showComplete = false
                round = 1
                score = 0
                setupRound()
            }

            Button("Done") { dismiss() }
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(.ultraThickMaterial)
                .shadow(radius: 20)
        )
        .padding(30)
    }
}
