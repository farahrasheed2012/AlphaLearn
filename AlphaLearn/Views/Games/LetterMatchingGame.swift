import SwiftUI

// MARK: - Letter Matching Game

/// Match each letter to its corresponding picture/word.
/// Shows 4 letters and 4 images; child taps a letter then taps the matching image.
struct LetterMatchingGame: View {
    @EnvironmentObject var progress: ProgressModel
    @Environment(\.dismiss) var dismiss

    @State private var currentLetters: [LetterItem] = []
    @State private var shuffledImages: [LetterItem] = []
    @State private var selectedLetter: LetterItem?
    @State private var matchedPairs: Set<String> = []
    @State private var wrongPair: String?
    @State private var score = 0
    @State private var round = 1
    @State private var showConfetti = false
    @State private var showComplete = false
    @State private var message = "Tap a letter, then tap its picture!"

    private let audio = AudioService.shared
    private let totalRounds = 3

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 20) {
                // Header
                gameHeader

                // Message
                Text(message)
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Letters row
                HStack(spacing: 14) {
                    ForEach(currentLetters) { letter in
                        letterButton(letter)
                    }
                }

                Text("⬇️ Match to ⬇️")
                    .font(.subheadline.bold())
                    .foregroundColor(.secondary)

                // Images row
                HStack(spacing: 14) {
                    ForEach(shuffledImages) { letter in
                        imageButton(letter)
                    }
                }

                Spacer()

                // Score
                HStack {
                    Text("⭐ Score: \(score)")
                        .font(.title3.bold())
                    Spacer()
                    Text("Round \(round)/\(totalRounds)")
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 30)
                .padding(.bottom)
            }
            .padding(.top)

            ConfettiView(isActive: $showConfetti)

            if showComplete {
                completionOverlay
            }
        }
        .navigationTitle("Letter Matching")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setupRound()
            audio.speakInstruction("Match each letter to its picture!")
        }
    }

    // MARK: - Game Header

    private var gameHeader: some View {
        HStack {
            ForEach(0..<totalRounds, id: \.self) { i in
                Circle()
                    .fill(i < round ? Color.green : Color.gray.opacity(0.3))
                    .frame(width: 16, height: 16)
            }
        }
        .padding(.top)
    }

    // MARK: - Letter Button

    private func letterButton(_ letter: LetterItem) -> some View {
        Button {
            selectLetter(letter)
        } label: {
            Text(letter.uppercase)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 70, height: 70)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(matchedPairs.contains(letter.id)
                              ? Color.green.gradient
                              : (selectedLetter?.id == letter.id
                                 ? Color.orange.gradient
                                 : letter.color.gradient))
                )
                .shadow(radius: 3)
        }
        .disabled(matchedPairs.contains(letter.id))
        .opacity(matchedPairs.contains(letter.id) ? 0.5 : 1)
    }

    // MARK: - Image Button

    private func imageButton(_ letter: LetterItem) -> some View {
        Button {
            selectImage(letter)
        } label: {
            VStack(spacing: 4) {
                Text(letter.emoji)
                    .font(.system(size: 36))
                Text(letter.word)
                    .font(.caption2.bold())
                    .foregroundColor(.primary)
            }
            .frame(width: 70, height: 70)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(matchedPairs.contains(letter.id)
                          ? Color.green.opacity(0.2)
                          : (wrongPair == letter.id
                             ? Color.red.opacity(0.2)
                             : Color(.systemGray6)))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(matchedPairs.contains(letter.id) ? Color.green : Color.clear, lineWidth: 2)
            )
        }
        .disabled(matchedPairs.contains(letter.id))
        .opacity(matchedPairs.contains(letter.id) ? 0.5 : 1)
    }

    // MARK: - Logic

    private func setupRound() {
        let letters = AlphabetData.letters.shuffled().prefix(4)
        currentLetters = Array(letters)
        shuffledImages = currentLetters.shuffled()
        selectedLetter = nil
        matchedPairs = []
        wrongPair = nil
        message = "Tap a letter, then tap its picture!"
    }

    private func selectLetter(_ letter: LetterItem) {
        selectedLetter = letter
        audio.speakLetter(letter.uppercase)
        audio.hapticLight()
        message = "Now find the picture for \(letter.uppercase)!"
    }

    private func selectImage(_ imageLetter: LetterItem) {
        guard let selected = selectedLetter else {
            message = "First tap a letter above!"
            return
        }

        if selected.id == imageLetter.id {
            // Correct match!
            matchedPairs.insert(selected.id)
            score += 1
            selectedLetter = nil
            message = CheerMessages.randomSuccess()
            audio.playSuccess()
            audio.hapticSuccess()
            audio.speakWord(imageLetter.word)

            // Check if round complete
            if matchedPairs.count == currentLetters.count {
                handleRoundComplete()
            }
        } else {
            // Wrong match
            wrongPair = imageLetter.id
            message = CheerMessages.randomEncouragement()
            audio.playTryAgain()
            audio.hapticError()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                wrongPair = nil
            }
        }
    }

    private func handleRoundComplete() {
        if round < totalRounds {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                round += 1
                setupRound()
            }
        } else {
            showConfetti = true
            showComplete = true
            progress.recordGameCompletion(gameType: .matching, stars: score)
            ProgressStore.shared.save(progress)
            audio.playCelebration()
        }
    }

    // MARK: - Completion Overlay

    private var completionOverlay: some View {
        VStack(spacing: 20) {
            Text("🎉")
                .font(.system(size: 80))
            Text("Great Job!")
                .font(.largeTitle.bold())
            Text("You earned \(score) ⭐ stars!")
                .font(.title3)
            HStack {
                ForEach(0..<min(score, 12), id: \.self) { _ in
                    Text("⭐").font(.title2)
                }
            }

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
