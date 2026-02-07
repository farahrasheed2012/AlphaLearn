import SwiftUI

// MARK: - Badge Definition

/// A badge/sticker that can be earned through achievements
struct Badge: Identifiable {
    let id: String
    let name: String
    let description: String
    let emoji: String
    let color: Color
    let requirement: String // Human-readable unlock condition
}

// MARK: - All Available Badges

struct BadgeCatalog {
    static let all: [Badge] = [
        // Alphabet Explorer badges
        Badge(id: "explorer_5", name: "Letter Explorer",
              description: "Viewed 5 letters!", emoji: "🔤",
              color: .blue, requirement: "View 5 letters"),
        Badge(id: "explorer_half", name: "Halfway Hero",
              description: "Viewed half the alphabet!", emoji: "🌟",
              color: .yellow, requirement: "View 13 letters"),
        Badge(id: "explorer_all", name: "Alphabet Champion",
              description: "Viewed the whole alphabet!", emoji: "🏆",
              color: .orange, requirement: "View all 26 letters"),

        // Tracing badges
        Badge(id: "tracer_5", name: "Pencil Starter",
              description: "Traced 5 letters!", emoji: "✏️",
              color: .green, requirement: "Trace 5 letters"),
        Badge(id: "tracer_half", name: "Writing Wizard",
              description: "Traced half the alphabet!", emoji: "🪄",
              color: .purple, requirement: "Trace 13 letters"),
        Badge(id: "tracer_all", name: "Master Writer",
              description: "Traced every letter!", emoji: "📝",
              color: .indigo, requirement: "Trace all 26 letters"),

        // Game badges
        Badge(id: "gamer_first", name: "Game On!",
              description: "Completed your first game!", emoji: "🎮",
              color: .cyan, requirement: "Complete 1 game"),
        Badge(id: "gamer_10", name: "Game Player",
              description: "Completed 10 games!", emoji: "🕹️",
              color: .teal, requirement: "Complete 10 games"),
        Badge(id: "gamer_25", name: "Game Master",
              description: "Completed 25 games!", emoji: "👾",
              color: .mint, requirement: "Complete 25 games"),

        // Star badges
        Badge(id: "star_10", name: "Rising Star",
              description: "Earned 10 stars!", emoji: "⭐",
              color: .yellow, requirement: "Earn 10 stars"),
        Badge(id: "star_50", name: "Superstar",
              description: "Earned 50 stars!", emoji: "🌟",
              color: .orange, requirement: "Earn 50 stars"),
        Badge(id: "star_100", name: "Megastar",
              description: "Earned 100 stars!", emoji: "💫",
              color: .red, requirement: "Earn 100 stars"),

        // Streak badges
        Badge(id: "streak_3", name: "3-Day Streak",
              description: "Practiced 3 days in a row!", emoji: "🔥",
              color: .red, requirement: "3-day practice streak"),
        Badge(id: "streak_7", name: "Week Warrior",
              description: "Practiced 7 days in a row!", emoji: "💪",
              color: .orange, requirement: "7-day practice streak"),
    ]

    /// Look up badge by ID
    static func badge(for id: String) -> Badge? {
        all.first { $0.id == id }
    }
}

// MARK: - Cheerful Messages

/// Random positive reinforcement messages
struct CheerMessages {
    static let success = [
        "You did it! 🎉",
        "Great job! ⭐",
        "Awesome! 🌟",
        "Way to go! 🚀",
        "Super! 💪",
        "Amazing work! 🏆",
        "Fantastic! 🎊",
        "Wonderful! 🌈",
        "You're a star! ⭐",
        "Keep it up! 👏",
    ]

    static let encouragement = [
        "You can do it! 💪",
        "Try again! 🌟",
        "Almost there! 🎯",
        "Keep trying! 💖",
        "You're doing great! 🌈",
        "Don't give up! 🚀",
    ]

    static func randomSuccess() -> String {
        success.randomElement() ?? "Great job!"
    }

    static func randomEncouragement() -> String {
        encouragement.randomElement() ?? "Keep trying!"
    }
}
