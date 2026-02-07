import SwiftUI

// MARK: - Bubble Pop Game (Creative Mini-Game)

/// Bubbles with letters float around the screen. The app says a letter
/// and the child must pop the correct bubble before it floats away.
struct BubblePopGame: View {
    @EnvironmentObject var progress: ProgressModel
    @Environment(\.dismiss) var dismiss

    @State private var bubbles: [Bubble] = []
    @State private var targetLetter: LetterItem = AlphabetData.letters[0]
    @State private var score = 0
    @State private var round = 1
    @State private var showConfetti = false
    @State private var showComplete = false
    @State private var message = "Pop the right bubble!"
    @State private var poppedId: UUID?
    @State private var timer: Timer?

    private let audio = AudioService.shared
    private let totalRounds = 8

    struct Bubble: Identifiable {
        let id = UUID()
        let letter: LetterItem
        var x: CGFloat
        var y: CGFloat
        let size: CGFloat
        let color: Color
    }

    var body: some View {
        ZStack {
            // Sky gradient background
            LinearGradient(
                colors: [.cyan.opacity(0.3), .blue.opacity(0.2), .purple.opacity(0.15)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {
                // Header
                HStack {
                    Text("⭐ \(score)")
                        .font(.title2.bold())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(.ultraThinMaterial))

                    Spacer()

                    Text("Round \(round)/\(totalRounds)")
                        .font(.subheadline.bold())
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(.ultraThinMaterial))
                }
                .padding()

                // Target instruction
                VStack(spacing: 4) {
                    Text("Pop the bubble with:")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    HStack(spacing: 8) {
                        Text(targetLetter.uppercase)
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(targetLetter.color)

                        Button {
                            audio.speakLetter(targetLetter.uppercase)
                        } label: {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.title3)
                                .foregroundColor(targetLetter.color)
                        }
                    }
                }

                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)

                Spacer()
            }

            // Floating bubbles
            GeometryReader { geo in
                ForEach(bubbles) { bubble in
                    BubbleView(
                        letter: bubble.letter.uppercase,
                        color: bubble.color,
                        size: bubble.size,
                        isPopped: poppedId == bubble.id
                    )
                    .position(x: bubble.x, y: bubble.y)
                    .onTapGesture {
                        popBubble(bubble)
                    }
                    .animation(
                        .easeInOut(duration: 2).repeatForever(autoreverses: true),
                        value: bubble.y
                    )
                }
            }

            ConfettiView(isActive: $showConfetti)

            if showComplete { completionOverlay }
        }
        .navigationTitle("Bubble Pop")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setupRound()
            audio.speakInstruction("Pop the bubble with the right letter!")
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    // MARK: - Logic

    private func setupRound() {
        targetLetter = AlphabetData.letters.randomElement()!
        poppedId = nil
        message = "Pop the bubble with \(targetLetter.uppercase)!"

        // Create 5-6 bubbles
        var newBubbles: [Bubble] = []
        // Ensure target is included
        newBubbles.append(makeBubble(for: targetLetter))

        // Add distractors
        var used = Set([targetLetter.id])
        while newBubbles.count < 6 {
            if let random = AlphabetData.letters.randomElement(), !used.contains(random.id) {
                used.insert(random.id)
                newBubbles.append(makeBubble(for: random))
            }
        }
        bubbles = newBubbles.shuffled()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            audio.speakLetter(targetLetter.uppercase)
        }

        // Animate bubbles floating
        startBubbleAnimation()
    }

    private func makeBubble(for letter: LetterItem) -> Bubble {
        Bubble(
            letter: letter,
            x: CGFloat.random(in: 60...320),
            y: CGFloat.random(in: 300...600),
            size: CGFloat.random(in: 65...85),
            color: letter.color
        )
    }

    private func startBubbleAnimation() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 1.5)) {
                for i in bubbles.indices {
                    bubbles[i].y += CGFloat.random(in: -30...30)
                    bubbles[i].x += CGFloat.random(in: -15...15)
                    bubbles[i].y = max(250, min(650, bubbles[i].y))
                    bubbles[i].x = max(50, min(340, bubbles[i].x))
                }
            }
        }
    }

    private func popBubble(_ bubble: Bubble) {
        if bubble.letter.id == targetLetter.id {
            poppedId = bubble.id
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
            message = "That's \(bubble.letter.uppercase), try again!"
            audio.playTryAgain()
            audio.hapticError()
        }
    }

    private func finishGame() {
        timer?.invalidate()
        showConfetti = true
        showComplete = true
        progress.recordGameCompletion(gameType: .bubblePop, stars: score)
        ProgressStore.shared.save(progress)
        audio.playCelebration()
    }

    // MARK: - Completion

    private var completionOverlay: some View {
        VStack(spacing: 20) {
            Text("🫧").font(.system(size: 80))
            Text("Bubble Master!").font(.largeTitle.bold())
            Text("You popped \(score) correct bubbles!").font(.title3)

            KidButton(title: "Play Again", emoji: "🔄", color: .cyan) {
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

// MARK: - Bubble View

struct BubbleView: View {
    let letter: String
    let color: Color
    let size: CGFloat
    let isPopped: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.6), color.opacity(0.3), .white.opacity(0.1)],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: size
                    )
                )
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .stroke(color.opacity(0.5), lineWidth: 1)
                )
                .shadow(color: color.opacity(0.3), radius: 8)

            // Shine highlight
            Circle()
                .fill(.white.opacity(0.4))
                .frame(width: size * 0.25, height: size * 0.25)
                .offset(x: -size * 0.15, y: -size * 0.15)

            Text(letter)
                .font(.system(size: size * 0.4, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .scaleEffect(isPopped ? 1.5 : 1.0)
        .opacity(isPopped ? 0 : 1)
        .animation(.spring(response: 0.3), value: isPopped)
    }
}
