import SwiftUI

// MARK: - Letter Detail View

/// Full-screen view for a single letter showing the letter, word, emoji,
/// audio playback buttons, and navigation to tracing
struct LetterDetailView: View {
    @EnvironmentObject var progress: ProgressModel
    let letter: LetterItem
    var startTracing: Bool = false

    @State private var showTracing = false
    @State private var showStarBurst = false
    @State private var animateEmoji = false
    @State private var showUppercase = true

    private let audio = AudioService.shared

    var body: some View {
        ZStack {
            // Background
            letter.color.opacity(0.1).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {

                    // Big letter display
                    letterDisplay

                    // Emoji and word
                    wordDisplay

                    // Audio buttons
                    audioButtons

                    // Toggle case
                    caseToggle

                    // Trace button
                    KidButton(title: "Trace This Letter", emoji: "✏️", color: .purple) {
                        showTracing = true
                    }

                    // Navigation arrows
                    navigationRow

                    Spacer(minLength: 40)
                }
                .padding()
            }

            // Celebration overlay
            StarBurstView(isActive: $showStarBurst)
        }
        .navigationTitle("\(letter.uppercase) is for \(letter.word)")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            progress.markLetterViewed(letter.id)
            ProgressStore.shared.save(progress)
            audio.speakLetter(letter.uppercase)
        }
        .fullScreenCover(isPresented: $showTracing) {
            TracingView(letter: letter)
                .environmentObject(progress)
        }
        .onAppear {
            if startTracing {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showTracing = true
                }
            }
        }
    }

    // MARK: - Letter Display

    private var letterDisplay: some View {
        ZStack {
            Circle()
                .fill(letter.color.gradient)
                .frame(width: 180, height: 180)
                .shadow(color: letter.color.opacity(0.4), radius: 12, y: 6)

            Text(showUppercase ? letter.uppercase : letter.lowercase)
                .font(.system(size: 100, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .transition(.scale.combined(with: .opacity))
                .id(showUppercase) // Force re-render on toggle
        }
        .sparkle(when: showStarBurst)
        .onTapGesture {
            showStarBurst = true
            audio.speakLetter(showUppercase ? letter.uppercase : letter.lowercase)
            audio.playSparkle()
        }
    }

    // MARK: - Word Display

    private var wordDisplay: some View {
        VStack(spacing: 8) {
            Text(letter.emoji)
                .font(.system(size: 80))
                .scaleEffect(animateEmoji ? 1.1 : 1.0)
                .animation(
                    .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                    value: animateEmoji
                )
                .onAppear { animateEmoji = true }
                .onTapGesture {
                    audio.speakWord(letter.word)
                    audio.hapticLight()
                }

            Text("\(letter.uppercase) is for \(letter.word)")
                .font(.title2.bold())
                .foregroundColor(.primary)
        }
    }

    // MARK: - Audio Buttons

    private var audioButtons: some View {
        HStack(spacing: 16) {
            KidButton(title: "Letter", emoji: "🔊", color: .blue) {
                audio.speakLetter(letter.uppercase)
            }

            KidButton(title: "Sound", emoji: "🎵", color: .green) {
                audio.speakLetterSound(letter.uppercase)
            }

            KidButton(title: "Word", emoji: "📢", color: .orange) {
                audio.speakWord(letter.word)
            }
        }
    }

    // MARK: - Case Toggle

    private var caseToggle: some View {
        Button {
            withAnimation(.spring()) {
                showUppercase.toggle()
            }
            audio.playTap()
        } label: {
            HStack {
                Text("Show:")
                    .foregroundColor(.secondary)
                Text(showUppercase ? "UPPERCASE" : "lowercase")
                    .bold()
                    .foregroundColor(letter.color)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Capsule().fill(.ultraThinMaterial))
        }
    }

    // MARK: - Navigation Row

    private var navigationRow: some View {
        HStack {
            if let prev = previousLetter {
                NavigationLink {
                    LetterDetailView(letter: prev)
                        .environmentObject(progress)
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text(prev.uppercase)
                            .bold()
                    }
                    .foregroundColor(prev.color)
                    .padding()
                    .background(Capsule().fill(.ultraThinMaterial))
                }
            }

            Spacer()

            if let next = nextLetter {
                NavigationLink {
                    LetterDetailView(letter: next)
                        .environmentObject(progress)
                } label: {
                    HStack {
                        Text(next.uppercase)
                            .bold()
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(next.color)
                    .padding()
                    .background(Capsule().fill(.ultraThinMaterial))
                }
            }
        }
    }

    private var previousLetter: LetterItem? {
        guard let idx = AlphabetData.letters.firstIndex(where: { $0.id == letter.id }),
              idx > 0 else { return nil }
        return AlphabetData.letters[idx - 1]
    }

    private var nextLetter: LetterItem? {
        guard let idx = AlphabetData.letters.firstIndex(where: { $0.id == letter.id }),
              idx < AlphabetData.letters.count - 1 else { return nil }
        return AlphabetData.letters[idx + 1]
    }
}
