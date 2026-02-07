import SwiftUI

// MARK: - Rewards View

/// Virtual sticker board / collection area displaying earned badges and stickers
struct RewardsView: View {
    @EnvironmentObject var progress: ProgressModel
    @State private var selectedBadge: Badge?
    @State private var showBadgeDetail = false

    let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 130), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Stars header
                starsHeader

                // Sticker board title
                VStack(spacing: 4) {
                    Text("🏆 My Sticker Board")
                        .font(.title2.bold())
                    Text("\(progress.earnedBadges.count) of \(BadgeCatalog.all.count) badges earned")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                // Badge grid
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(BadgeCatalog.all) { badge in
                        BadgeTile(
                            badge: badge,
                            isEarned: progress.earnedBadges.contains(badge.id)
                        )
                        .onTapGesture {
                            selectedBadge = badge
                            showBadgeDetail = true
                            if progress.earnedBadges.contains(badge.id) {
                                AudioService.shared.playSparkle()
                            }
                        }
                    }
                }
                .padding(.horizontal)

                Spacer(minLength: 30)
            }
            .padding(.top)
        }
        .navigationTitle("My Rewards")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showBadgeDetail) {
            if let badge = selectedBadge {
                BadgeDetailSheet(
                    badge: badge,
                    isEarned: progress.earnedBadges.contains(badge.id)
                )
            }
        }
    }

    // MARK: - Stars Header

    private var starsHeader: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                ForEach(0..<min(5, max(1, progress.totalStars / 10)), id: \.self) { _ in
                    BouncingEmoji("⭐", size: 30)
                }
            }
            Text("\(progress.totalStars) Stars Collected!")
                .font(.title3.bold())
                .foregroundColor(.orange)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.yellow.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
}

// MARK: - Badge Tile

struct BadgeTile: View {
    let badge: Badge
    let isEarned: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isEarned ? badge.color.gradient : Color.gray.opacity(0.2).gradient)
                    .frame(width: 70, height: 70)
                    .shadow(color: isEarned ? badge.color.opacity(0.3) : .clear, radius: 6)

                if isEarned {
                    Text(badge.emoji)
                        .font(.system(size: 35))
                } else {
                    Image(systemName: "lock.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }

            Text(badge.name)
                .font(.caption2.bold())
                .multilineTextAlignment(.center)
                .foregroundColor(isEarned ? .primary : .secondary)
                .lineLimit(2)
                .frame(width: 90)
        }
    }
}

// MARK: - Badge Detail Sheet

struct BadgeDetailSheet: View {
    let badge: Badge
    let isEarned: Bool
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            // Badge display
            ZStack {
                Circle()
                    .fill(isEarned ? badge.color.gradient : Color.gray.opacity(0.2).gradient)
                    .frame(width: 140, height: 140)
                    .shadow(color: isEarned ? badge.color.opacity(0.4) : .clear, radius: 12)

                Text(badge.emoji)
                    .font(.system(size: isEarned ? 70 : 50))
                    .opacity(isEarned ? 1 : 0.3)
            }

            Text(badge.name)
                .font(.title.bold())
                .foregroundColor(isEarned ? .primary : .secondary)

            Text(badge.description)
                .font(.title3)
                .foregroundColor(.secondary)

            if isEarned {
                Text("✅ Earned!")
                    .font(.headline)
                    .foregroundColor(.green)
                    .padding()
                    .background(Capsule().fill(Color.green.opacity(0.1)))
            } else {
                VStack(spacing: 4) {
                    Text("🔒 Locked")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("How to unlock: \(badge.requirement)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Button("Close") { dismiss() }
                .font(.headline)
                .foregroundColor(.blue)
                .padding()
        }
        .padding()
    }
}
