import SwiftUI

// MARK: - Games Menu View

/// Fun menu showing all available mini-games
struct GamesMenuView: View {
    @EnvironmentObject var progress: ProgressModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("🎮")
                        .font(.system(size: 60))
                    Text("Pick a Game!")
                        .font(.title.bold())
                    Text("Learn letters while having fun!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)

                // Game cards
                VStack(spacing: 16) {
                    NavigationLink {
                        LetterMatchingGame()
                            .environmentObject(progress)
                    } label: {
                        GameCard(
                            game: .matching,
                            completed: progress.matchingGamesCompleted
                        )
                    }

                    NavigationLink {
                        FindTheLetterGame()
                            .environmentObject(progress)
                    } label: {
                        GameCard(
                            game: .findLetter,
                            completed: progress.findLetterRoundsCompleted
                        )
                    }

                    NavigationLink {
                        AlphabetPuzzleGame()
                            .environmentObject(progress)
                    } label: {
                        GameCard(
                            game: .puzzle,
                            completed: progress.puzzlesCompleted
                        )
                    }

                    NavigationLink {
                        BubblePopGame()
                            .environmentObject(progress)
                    } label: {
                        GameCard(
                            game: .bubblePop,
                            completed: progress.bubblePopCompleted
                        )
                    }
                }
                .padding(.horizontal)

                Spacer(minLength: 30)
            }
        }
        .navigationTitle("Games")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Game Card

struct GameCard: View {
    let game: GameType
    let completed: Int

    var body: some View {
        HStack(spacing: 16) {
            Text(game.emoji)
                .font(.system(size: 44))
                .frame(width: 60, height: 60)

            VStack(alignment: .leading, spacing: 4) {
                Text(game.rawValue)
                    .font(.title3.bold())
                    .foregroundColor(.primary)
                Text("Played \(completed) time\(completed == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "play.circle.fill")
                .font(.title)
                .foregroundColor(game.color)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(game.color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(game.color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}
