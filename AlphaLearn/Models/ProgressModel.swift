import Foundation

// MARK: - Progress Model

/// Tracks a child's learning progress across letters, games, and tracing
class ProgressModel: ObservableObject, Codable {

    // MARK: - Letter Progress
    /// Set of letter IDs (A-Z) the child has viewed/practiced
    @Published var viewedLetters: Set<String> = []
    /// Set of letter IDs the child has successfully traced
    @Published var tracedLetters: Set<String> = []

    // MARK: - Game Scores
    /// Number of Letter Matching games completed
    @Published var matchingGamesCompleted: Int = 0
    /// Number of Find The Letter rounds completed
    @Published var findLetterRoundsCompleted: Int = 0
    /// Number of Puzzle words completed
    @Published var puzzlesCompleted: Int = 0
    /// Number of Bubble Pop rounds completed
    @Published var bubblePopCompleted: Int = 0

    // MARK: - Streaks & Stats
    /// Total stars earned across all activities
    @Published var totalStars: Int = 0
    /// Current daily streak (how many days in a row the child has practiced)
    @Published var dailyStreak: Int = 0
    /// Date of last practice session
    @Published var lastPracticeDate: Date?
    /// Total time spent in app (seconds)
    @Published var totalPracticeSeconds: Int = 0

    // MARK: - Badges Earned
    /// Set of badge IDs the child has unlocked
    @Published var earnedBadges: Set<String> = []

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case viewedLetters, tracedLetters
        case matchingGamesCompleted, findLetterRoundsCompleted
        case puzzlesCompleted, bubblePopCompleted
        case totalStars, dailyStreak, lastPracticeDate, totalPracticeSeconds
        case earnedBadges
    }

    init() {}

    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        viewedLetters = try c.decodeIfPresent(Set<String>.self, forKey: .viewedLetters) ?? []
        tracedLetters = try c.decodeIfPresent(Set<String>.self, forKey: .tracedLetters) ?? []
        matchingGamesCompleted = try c.decodeIfPresent(Int.self, forKey: .matchingGamesCompleted) ?? 0
        findLetterRoundsCompleted = try c.decodeIfPresent(Int.self, forKey: .findLetterRoundsCompleted) ?? 0
        puzzlesCompleted = try c.decodeIfPresent(Int.self, forKey: .puzzlesCompleted) ?? 0
        bubblePopCompleted = try c.decodeIfPresent(Int.self, forKey: .bubblePopCompleted) ?? 0
        totalStars = try c.decodeIfPresent(Int.self, forKey: .totalStars) ?? 0
        dailyStreak = try c.decodeIfPresent(Int.self, forKey: .dailyStreak) ?? 0
        lastPracticeDate = try c.decodeIfPresent(Date.self, forKey: .lastPracticeDate)
        totalPracticeSeconds = try c.decodeIfPresent(Int.self, forKey: .totalPracticeSeconds) ?? 0
        earnedBadges = try c.decodeIfPresent(Set<String>.self, forKey: .earnedBadges) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(viewedLetters, forKey: .viewedLetters)
        try c.encode(tracedLetters, forKey: .tracedLetters)
        try c.encode(matchingGamesCompleted, forKey: .matchingGamesCompleted)
        try c.encode(findLetterRoundsCompleted, forKey: .findLetterRoundsCompleted)
        try c.encode(puzzlesCompleted, forKey: .puzzlesCompleted)
        try c.encode(bubblePopCompleted, forKey: .bubblePopCompleted)
        try c.encode(totalStars, forKey: .totalStars)
        try c.encode(dailyStreak, forKey: .dailyStreak)
        try c.encode(lastPracticeDate, forKey: .lastPracticeDate)
        try c.encode(totalPracticeSeconds, forKey: .totalPracticeSeconds)
        try c.encode(earnedBadges, forKey: .earnedBadges)
    }

    // MARK: - Convenience

    /// Percentage of alphabet viewed (0-1)
    var alphabetProgress: Double {
        Double(viewedLetters.count) / 26.0
    }

    /// Percentage of alphabet traced (0-1)
    var tracingProgress: Double {
        Double(tracedLetters.count) / 26.0
    }

    /// Total games completed across all types
    var totalGamesCompleted: Int {
        matchingGamesCompleted + findLetterRoundsCompleted + puzzlesCompleted + bubblePopCompleted
    }

    // MARK: - Actions

    /// Record that a letter was viewed
    func markLetterViewed(_ id: String) {
        viewedLetters.insert(id.uppercased())
        awardStars(1)
        updateStreak()
        checkBadges()
    }

    /// Record that a letter was successfully traced
    func markLetterTraced(_ id: String) {
        tracedLetters.insert(id.uppercased())
        awardStars(2)
        updateStreak()
        checkBadges()
    }

    /// Record a game completion and award stars
    func recordGameCompletion(gameType: GameType, stars: Int = 3) {
        switch gameType {
        case .matching:     matchingGamesCompleted += 1
        case .findLetter:   findLetterRoundsCompleted += 1
        case .puzzle:       puzzlesCompleted += 1
        case .bubblePop:    bubblePopCompleted += 1
        }
        awardStars(stars)
        updateStreak()
        checkBadges()
    }

    /// Add stars to total
    func awardStars(_ count: Int) {
        totalStars += count
    }

    /// Update the daily streak
    private func updateStreak() {
        let now = Date()
        if let last = lastPracticeDate {
            let cal = Calendar.current
            if cal.isDateInToday(last) {
                // Same day, streak stays
            } else if cal.isDateInYesterday(last) {
                dailyStreak += 1
            } else {
                dailyStreak = 1
            }
        } else {
            dailyStreak = 1
        }
        lastPracticeDate = now
    }

    /// Check and award badges based on progress
    private func checkBadges() {
        // Alphabet explorer badges
        if viewedLetters.count >= 5 { earnedBadges.insert("explorer_5") }
        if viewedLetters.count >= 13 { earnedBadges.insert("explorer_half") }
        if viewedLetters.count >= 26 { earnedBadges.insert("explorer_all") }

        // Tracing badges
        if tracedLetters.count >= 5 { earnedBadges.insert("tracer_5") }
        if tracedLetters.count >= 13 { earnedBadges.insert("tracer_half") }
        if tracedLetters.count >= 26 { earnedBadges.insert("tracer_all") }

        // Game badges
        if totalGamesCompleted >= 1 { earnedBadges.insert("gamer_first") }
        if totalGamesCompleted >= 10 { earnedBadges.insert("gamer_10") }
        if totalGamesCompleted >= 25 { earnedBadges.insert("gamer_25") }

        // Star badges
        if totalStars >= 10 { earnedBadges.insert("star_10") }
        if totalStars >= 50 { earnedBadges.insert("star_50") }
        if totalStars >= 100 { earnedBadges.insert("star_100") }

        // Streak badges
        if dailyStreak >= 3 { earnedBadges.insert("streak_3") }
        if dailyStreak >= 7 { earnedBadges.insert("streak_7") }
    }
}

// MARK: - Game Type

enum GameType: String, CaseIterable, Identifiable {
    case matching = "Letter Matching"
    case findLetter = "Find the Letter"
    case puzzle = "Alphabet Puzzle"
    case bubblePop = "Bubble Pop"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .matching:   return "rectangle.on.rectangle"
        case .findLetter: return "magnifyingglass"
        case .puzzle:     return "puzzlepiece.fill"
        case .bubblePop:  return "bubble.left.and.bubble.right.fill"
        }
    }

    var color: Color {
        switch self {
        case .matching:   return .blue
        case .findLetter: return .green
        case .puzzle:     return .purple
        case .bubblePop:  return .orange
        }
    }

    var emoji: String {
        switch self {
        case .matching:   return "🃏"
        case .findLetter: return "🔍"
        case .puzzle:     return "🧩"
        case .bubblePop:  return "🫧"
        }
    }
}

import SwiftUI // needed for Color in GameType
