import SwiftUI

// MARK: - Alphabet View

/// Grid display of all 26 letters; tap to explore or trace
struct AlphabetView: View {
    @EnvironmentObject var progress: ProgressModel
    var startInTracingMode: Bool = false

    let columns = [
        GridItem(.adaptive(minimum: 80, maximum: 100), spacing: 14)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                Text(startInTracingMode ? "Trace a Letter ✏️" : "Tap a Letter! 🔤")
                    .font(.title2.bold())
                    .padding(.top)

                // Letter grid
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(AlphabetData.letters) { letter in
                        NavigationLink {
                            LetterDetailView(letter: letter, startTracing: startInTracingMode)
                                .environmentObject(progress)
                        } label: {
                            LetterGridCell(
                                letter: letter,
                                isViewed: progress.viewedLetters.contains(letter.id),
                                isTraced: progress.tracedLetters.contains(letter.id)
                            )
                        }
                    }
                }
                .padding(.horizontal)

                Spacer(minLength: 30)
            }
        }
        .navigationTitle(startInTracingMode ? "Trace Letters" : "Alphabet")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Letter Grid Cell

struct LetterGridCell: View {
    let letter: LetterItem
    let isViewed: Bool
    let isTraced: Bool

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(letter.color.gradient)
                    .frame(width: 75, height: 75)
                    .shadow(color: letter.color.opacity(0.3), radius: 4, y: 2)

                VStack(spacing: 0) {
                    Text(letter.uppercase)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text(letter.lowercase)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .overlay(alignment: .topTrailing) {
                if isTraced {
                    Text("✅")
                        .font(.caption)
                        .offset(x: 6, y: -6)
                } else if isViewed {
                    Text("👀")
                        .font(.caption)
                        .offset(x: 6, y: -6)
                }
            }

            Text(letter.emoji)
                .font(.title3)
        }
    }
}
