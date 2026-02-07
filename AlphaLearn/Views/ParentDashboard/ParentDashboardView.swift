import SwiftUI

// MARK: - Parent Dashboard View

/// Simple progress dashboard for parents showing learning stats
struct ParentDashboardView: View {
    @EnvironmentObject var progress: ProgressModel
    @Environment(\.dismiss) var dismiss
    @State private var showResetAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Overview cards
                    overviewSection

                    // Detailed stats
                    detailedStats

                    // Letters progress
                    lettersProgress

                    // Reset button
                    resetSection

                    Spacer(minLength: 30)
                }
                .padding()
            }
            .navigationTitle("Parent Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Reset Progress?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    ProgressStore.shared.reset()
                    // Reload with fresh model
                    progress.viewedLetters = []
                    progress.tracedLetters = []
                    progress.matchingGamesCompleted = 0
                    progress.findLetterRoundsCompleted = 0
                    progress.puzzlesCompleted = 0
                    progress.bubblePopCompleted = 0
                    progress.totalStars = 0
                    progress.dailyStreak = 0
                    progress.earnedBadges = []
                }
            } message: {
                Text("This will erase all learning progress, stars, and badges. This cannot be undone.")
            }
        }
    }

    // MARK: - Overview Section

    private var overviewSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            StatCard(title: "Stars Earned", value: "\(progress.totalStars)", icon: "star.fill", color: .yellow)
            StatCard(title: "Badges", value: "\(progress.earnedBadges.count)/\(BadgeCatalog.all.count)", icon: "trophy.fill", color: .orange)
            StatCard(title: "Letters Viewed", value: "\(progress.viewedLetters.count)/26", icon: "textformat.abc", color: .blue)
            StatCard(title: "Letters Traced", value: "\(progress.tracedLetters.count)/26", icon: "pencil.line", color: .purple)
        }
    }

    // MARK: - Detailed Stats

    private var detailedStats: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Game Progress")
                .font(.title3.bold())

            VStack(spacing: 12) {
                StatRow(game: .matching, count: progress.matchingGamesCompleted)
                StatRow(game: .findLetter, count: progress.findLetterRoundsCompleted)
                StatRow(game: .puzzle, count: progress.puzzlesCompleted)
                StatRow(game: .bubblePop, count: progress.bubblePopCompleted)
            }

            Divider()

            // Streak
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.red)
                Text("Daily Streak:")
                    .font(.headline)
                Spacer()
                Text("\(progress.dailyStreak) day\(progress.dailyStreak == 1 ? "" : "s")")
                    .font(.headline)
                    .foregroundColor(.red)
            }

            // Last practice
            if let lastDate = progress.lastPracticeDate {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.gray)
                    Text("Last Practice:")
                        .font(.subheadline)
                    Spacer()
                    Text(lastDate, style: .relative)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }

    // MARK: - Letters Progress

    private var lettersProgress: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Letter Progress")
                .font(.title3.bold())

            // Alphabet progress bars
            VStack(spacing: 8) {
                HStack {
                    Text("Viewed")
                    Spacer()
                    Text("\(Int(progress.alphabetProgress * 100))%")
                        .foregroundColor(.blue)
                }
                ProgressView(value: progress.alphabetProgress)
                    .tint(.blue)

                HStack {
                    Text("Traced")
                    Spacer()
                    Text("\(Int(progress.tracingProgress * 100))%")
                        .foregroundColor(.purple)
                }
                ProgressView(value: progress.tracingProgress)
                    .tint(.purple)
            }

            // Individual letter status
            let gridCols = [GridItem(.adaptive(minimum: 35))]
            LazyVGrid(columns: gridCols, spacing: 8) {
                ForEach(AlphabetData.letters) { letter in
                    VStack(spacing: 2) {
                        Text(letter.uppercase)
                            .font(.caption.bold())
                            .foregroundColor(letterStatusColor(letter.id))

                        Circle()
                            .fill(letterStatusColor(letter.id))
                            .frame(width: 8, height: 8)
                    }
                }
            }

            // Legend
            HStack(spacing: 16) {
                legendItem(color: .green, label: "Traced")
                legendItem(color: .blue, label: "Viewed")
                legendItem(color: .gray.opacity(0.3), label: "Not started")
            }
            .font(.caption)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }

    private func letterStatusColor(_ id: String) -> Color {
        if progress.tracedLetters.contains(id) { return .green }
        if progress.viewedLetters.contains(id) { return .blue }
        return .gray.opacity(0.3)
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label)
        }
    }

    // MARK: - Reset Section

    private var resetSection: some View {
        Button {
            showResetAlert = true
        } label: {
            HStack {
                Image(systemName: "arrow.counterclockwise")
                Text("Reset All Progress")
            }
            .font(.subheadline)
            .foregroundColor(.red)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(value)
                .font(.title2.bold())
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Stat Row

struct StatRow: View {
    let game: GameType
    let count: Int

    var body: some View {
        HStack {
            Text(game.emoji)
            Text(game.rawValue)
                .font(.subheadline)
            Spacer()
            Text("\(count) played")
                .font(.subheadline.bold())
                .foregroundColor(game.color)
        }
    }
}
