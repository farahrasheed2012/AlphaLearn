import SwiftUI

// MARK: - Alphabet Puzzle Game

/// Drag and drop letters to spell simple words.
/// Shows a word with blanks and a set of scrambled letters below.
struct AlphabetPuzzleGame: View {
    @EnvironmentObject var progress: ProgressModel
    @Environment(\.dismiss) var dismiss

    @State private var currentWord = ""
    @State private var currentEmoji = ""
    @State private var blanks: [String?] = []       // nil = empty slot
    @State private var availableLetters: [String] = []
    @State private var score = 0
    @State private var round = 1
    @State private var showConfetti = false
    @State private var showComplete = false
    @State private var message = "Tap the letters to spell the word!"
    @State private var isCorrect = false

    private let audio = AudioService.shared
    private let totalRounds = 5

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 24) {
                // Progress
                HStack {
                    ForEach(0..<totalRounds, id: \.self) { i in
                        Circle()
                            .fill(i < round ? Color.purple : Color.gray.opacity(0.3))
                            .frame(width: 12, height: 12)
                    }
                }
                .padding(.top)

                // Word image & hint
                VStack(spacing: 8) {
                    Text(currentEmoji)
                        .font(.system(size: 70))
                    Text("Spell: \(currentWord)")
                        .font(.title3.bold())
                        .foregroundColor(.purple)

                    Button {
                        audio.speakWord(currentWord.lowercased())
                    } label: {
                        Label("Hear Word", systemImage: "speaker.wave.2.fill")
                            .font(.subheadline)
                    }
                }

                // Message
                Text(message)
                    .font(.headline)
                    .foregroundColor(isCorrect ? .green : .secondary)

                // Blank slots
                HStack(spacing: 10) {
                    ForEach(blanks.indices, id: \.self) { i in
                        blankSlot(index: i)
                    }
                }

                // Available letters
                HStack(spacing: 10) {
                    ForEach(availableLetters.indices, id: \.self) { i in
                        if !availableLetters[i].isEmpty {
                            letterChoice(index: i)
                        } else {
                            // Empty placeholder
                            Color.clear
                                .frame(width: 55, height: 55)
                        }
                    }
                }
                .padding(.horizontal)

                // Reset button
                Button {
                    resetCurrentWord()
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Score
                HStack {
                    Text("⭐ \(score)")
                        .font(.title3.bold())
                    Spacer()
                    Text("Word \(round)/\(totalRounds)")
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 30)
                .padding(.bottom)
            }

            ConfettiView(isActive: $showConfetti)

            if showComplete { completionOverlay }
        }
        .navigationTitle("Alphabet Puzzle")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setupRound()
            audio.speakInstruction("Spell the word by tapping the letters!")
        }
    }

    // MARK: - Blank Slot

    private func blankSlot(index: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.purple, style: StrokeStyle(lineWidth: 2, dash: [6]))
                .frame(width: 55, height: 55)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(blanks[index] != nil ? Color.purple.opacity(0.1) : Color.clear)
                )

            if let letter = blanks[index] {
                Text(letter)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.purple)
            }
        }
        .onTapGesture {
            // Remove letter from blank, return to available
            if let letter = blanks[index] {
                blanks[index] = nil
                if let emptyIdx = availableLetters.firstIndex(of: "") {
                    availableLetters[emptyIdx] = letter
                } else {
                    availableLetters.append(letter)
                }
                isCorrect = false
                message = "Tap the letters to spell the word!"
                audio.playTap()
            }
        }
    }

    // MARK: - Letter Choice

    private func letterChoice(index: Int) -> some View {
        Button {
            placeLetter(from: index)
        } label: {
            Text(availableLetters[index])
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 55, height: 55)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.purple.gradient)
                        .shadow(radius: 2)
                )
        }
    }

    // MARK: - Logic

    private func setupRound() {
        let puzzle = AlphabetData.puzzleWords.shuffled().first!
        currentWord = puzzle.word
        currentEmoji = puzzle.emoji
        blanks = Array(repeating: nil, count: currentWord.count)

        // Create available letters (word letters + a few distractors)
        var letters = currentWord.map { String($0) }
        let distractors = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            .filter { !currentWord.contains($0) }
            .map { String($0) }
            .shuffled()
            .prefix(2)
        letters.append(contentsOf: distractors)
        availableLetters = letters.shuffled()

        isCorrect = false
        message = "Tap the letters to spell the word!"

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            audio.speakWord(currentWord.lowercased())
        }
    }

    private func placeLetter(from index: Int) {
        guard let blankIdx = blanks.firstIndex(where: { $0 == nil }) else { return }

        blanks[blankIdx] = availableLetters[index]
        availableLetters[index] = "" // Mark as used
        audio.playTap()
        audio.hapticLight()

        // Check if word is complete
        if blanks.allSatisfy({ $0 != nil }) {
            checkWord()
        }
    }

    private func checkWord() {
        let spelled = blanks.compactMap { $0 }.joined()
        if spelled == currentWord {
            isCorrect = true
            score += 3
            message = CheerMessages.randomSuccess()
            audio.playSuccess()
            audio.hapticSuccess()

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if round < totalRounds {
                    round += 1
                    setupRound()
                } else {
                    finishGame()
                }
            }
        } else {
            message = "Hmm, that's not right. Try again! 🤔"
            audio.playTryAgain()
            audio.hapticError()

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                resetCurrentWord()
            }
        }
    }

    private func resetCurrentWord() {
        var letters = currentWord.map { String($0) }
        let distractors = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            .filter { !currentWord.contains($0) }
            .map { String($0) }
            .shuffled()
            .prefix(2)
        letters.append(contentsOf: distractors)
        availableLetters = letters.shuffled()
        blanks = Array(repeating: nil, count: currentWord.count)
        isCorrect = false
        message = "Tap the letters to spell the word!"
    }

    private func finishGame() {
        showConfetti = true
        showComplete = true
        progress.recordGameCompletion(gameType: .puzzle, stars: score)
        ProgressStore.shared.save(progress)
        audio.playCelebration()
    }

    // MARK: - Completion

    private var completionOverlay: some View {
        VStack(spacing: 20) {
            Text("🧩").font(.system(size: 80))
            Text("Puzzle Master!").font(.largeTitle.bold())
            Text("You earned \(score) ⭐ stars!").font(.title3)

            KidButton(title: "Play Again", emoji: "🔄", color: .purple) {
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
