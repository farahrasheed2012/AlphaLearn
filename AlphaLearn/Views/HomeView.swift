import SwiftUI

// MARK: - Home View

/// Main landing screen with fun, colorful buttons for each app section
struct HomeView: View {
    @EnvironmentObject var progress: ProgressModel
    @State private var animate = false
    @State private var showParentDashboard = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Cheerful gradient background
                LinearGradient(
                    colors: [.yellow.opacity(0.3), .orange.opacity(0.2), .pink.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 30) {
                        // Title with bouncing letters
                        titleSection

                        // Stars counter
                        starsCounter

                        // Main navigation buttons
                        mainButtons

                        // Daily streak
                        if progress.dailyStreak > 0 {
                            streakBanner
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showParentDashboard = true
                    } label: {
                        Image(systemName: "person.circle")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .sheet(isPresented: $showParentDashboard) {
                ParentDashboardView()
                    .environmentObject(progress)
            }
        }
    }

    // MARK: - Title Section

    private var titleSection: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                ForEach(Array("AlphaLearn".enumerated()), id: \.offset) { i, char in
                    Text(String(char))
                        .font(.system(size: 38, weight: .heavy, design: .rounded))
                        .foregroundColor(rainbowColor(for: i))
                        .offset(y: animate ? -5 : 5)
                        .animation(
                            .easeInOut(duration: 0.5)
                            .repeatForever(autoreverses: true)
                            .delay(Double(i) * 0.08),
                            value: animate
                        )
                }
            }

            Text("Let's Learn the Alphabet!")
                .font(.title3.weight(.medium))
                .foregroundColor(.secondary)
        }
        .padding(.top, 10)
        .onAppear { animate = true }
    }

    private func rainbowColor(for index: Int) -> Color {
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink, .cyan, .mint, .indigo]
        return colors[index % colors.count]
    }

    // MARK: - Stars Counter

    private var starsCounter: some View {
        HStack(spacing: 6) {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
                .font(.title2)
            Text("\(progress.totalStars)")
                .font(.title2.bold())
                .foregroundColor(.orange)
            Text("stars")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(color: .yellow.opacity(0.3), radius: 8, y: 2)
        )
    }

    // MARK: - Main Navigation Buttons

    private var mainButtons: some View {
        VStack(spacing: 20) {
            // Alphabet
            NavigationLink {
                AlphabetView()
                    .environmentObject(progress)
            } label: {
                HomeCard(
                    title: "Learn Letters",
                    subtitle: "\(progress.viewedLetters.count)/26 explored",
                    emoji: "🔤",
                    color: .blue,
                    progress: progress.alphabetProgress
                )
            }

            // Games
            NavigationLink {
                GamesMenuView()
                    .environmentObject(progress)
            } label: {
                HomeCard(
                    title: "Play Games",
                    subtitle: "\(progress.totalGamesCompleted) games played",
                    emoji: "🎮",
                    color: .green,
                    progress: nil
                )
            }

            // Tracing
            NavigationLink {
                AlphabetView(startInTracingMode: true)
                    .environmentObject(progress)
            } label: {
                HomeCard(
                    title: "Trace Letters",
                    subtitle: "\(progress.tracedLetters.count)/26 traced",
                    emoji: "✏️",
                    color: .purple,
                    progress: progress.tracingProgress
                )
            }

            // Rewards
            NavigationLink {
                RewardsView()
                    .environmentObject(progress)
            } label: {
                HomeCard(
                    title: "My Rewards",
                    subtitle: "\(progress.earnedBadges.count) badges earned",
                    emoji: "🏆",
                    color: .orange,
                    progress: nil
                )
            }
        }
    }

    // MARK: - Streak Banner

    private var streakBanner: some View {
        HStack {
            Text("🔥")
                .font(.title)
            VStack(alignment: .leading) {
                Text("\(progress.dailyStreak)-Day Streak!")
                    .font(.headline.bold())
                Text("Keep learning every day!")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.red.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Home Card

/// A large, colorful navigation card for the home screen
struct HomeCard: View {
    let title: String
    let subtitle: String
    let emoji: String
    let color: Color
    let progress: Double?

    var body: some View {
        HStack(spacing: 16) {
            Text(emoji)
                .font(.system(size: 50))
                .frame(width: 70, height: 70)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if let progress = progress {
                    ProgressView(value: progress)
                        .tint(color)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.title3)
                .foregroundColor(color)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.background)
                .shadow(color: color.opacity(0.2), radius: 10, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}
