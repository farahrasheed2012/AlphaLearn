import SwiftUI

// MARK: - Letter Data Model

/// Represents a single letter of the alphabet with its associated learning content
struct LetterItem: Identifiable, Equatable {
    let id: String
    let uppercase: String
    let lowercase: String
    let word: String          // Example word (e.g. "Apple")
    let emoji: String         // Emoji placeholder for the image
    let color: Color          // Theme color for this letter
    let tracingPoints: [CGPoint] // Simplified tracing guide points

    static func == (lhs: LetterItem, rhs: LetterItem) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Complete Alphabet Data

/// All 26 letters with associated words, emoji, and colors
struct AlphabetData {
    static let letters: [LetterItem] = [
        LetterItem(id: "A", uppercase: "A", lowercase: "a", word: "Apple", emoji: "🍎",
                   color: .red, tracingPoints: Self.tracingA),
        LetterItem(id: "B", uppercase: "B", lowercase: "b", word: "Ball", emoji: "⚽",
                   color: .blue, tracingPoints: Self.tracingB),
        LetterItem(id: "C", uppercase: "C", lowercase: "c", word: "Cat", emoji: "🐱",
                   color: .orange, tracingPoints: Self.tracingC),
        LetterItem(id: "D", uppercase: "D", lowercase: "d", word: "Dog", emoji: "🐶",
                   color: .brown, tracingPoints: Self.tracingD),
        LetterItem(id: "E", uppercase: "E", lowercase: "e", word: "Elephant", emoji: "🐘",
                   color: .gray, tracingPoints: Self.tracingE),
        LetterItem(id: "F", uppercase: "F", lowercase: "f", word: "Fish", emoji: "🐟",
                   color: .cyan, tracingPoints: Self.tracingF),
        LetterItem(id: "G", uppercase: "G", lowercase: "g", word: "Grape", emoji: "🍇",
                   color: .purple, tracingPoints: Self.tracingG),
        LetterItem(id: "H", uppercase: "H", lowercase: "h", word: "Hat", emoji: "🎩",
                   color: .indigo, tracingPoints: Self.tracingH),
        LetterItem(id: "I", uppercase: "I", lowercase: "i", word: "Ice Cream", emoji: "🍦",
                   color: .pink, tracingPoints: Self.tracingI),
        LetterItem(id: "J", uppercase: "J", lowercase: "j", word: "Jellyfish", emoji: "🪼",
                   color: .teal, tracingPoints: Self.tracingJ),
        LetterItem(id: "K", uppercase: "K", lowercase: "k", word: "Kite", emoji: "🪁",
                   color: .mint, tracingPoints: Self.tracingK),
        LetterItem(id: "L", uppercase: "L", lowercase: "l", word: "Lion", emoji: "🦁",
                   color: .yellow, tracingPoints: Self.tracingL),
        LetterItem(id: "M", uppercase: "M", lowercase: "m", word: "Moon", emoji: "🌙",
                   color: .indigo, tracingPoints: Self.tracingM),
        LetterItem(id: "N", uppercase: "N", lowercase: "n", word: "Nest", emoji: "🪺",
                   color: .brown, tracingPoints: Self.tracingN),
        LetterItem(id: "O", uppercase: "O", lowercase: "o", word: "Orange", emoji: "🍊",
                   color: .orange, tracingPoints: Self.tracingO),
        LetterItem(id: "P", uppercase: "P", lowercase: "p", word: "Penguin", emoji: "🐧",
                   color: .blue, tracingPoints: Self.tracingP),
        LetterItem(id: "Q", uppercase: "Q", lowercase: "q", word: "Queen", emoji: "👑",
                   color: .yellow, tracingPoints: Self.tracingQ),
        LetterItem(id: "R", uppercase: "R", lowercase: "r", word: "Rainbow", emoji: "🌈",
                   color: .red, tracingPoints: Self.tracingR),
        LetterItem(id: "S", uppercase: "S", lowercase: "s", word: "Star", emoji: "⭐",
                   color: .yellow, tracingPoints: Self.tracingS),
        LetterItem(id: "T", uppercase: "T", lowercase: "t", word: "Tree", emoji: "🌳",
                   color: .green, tracingPoints: Self.tracingT),
        LetterItem(id: "U", uppercase: "U", lowercase: "u", word: "Umbrella", emoji: "☂️",
                   color: .purple, tracingPoints: Self.tracingU),
        LetterItem(id: "V", uppercase: "V", lowercase: "v", word: "Violin", emoji: "🎻",
                   color: .brown, tracingPoints: Self.tracingV),
        LetterItem(id: "W", uppercase: "W", lowercase: "w", word: "Whale", emoji: "🐳",
                   color: .blue, tracingPoints: Self.tracingW),
        LetterItem(id: "X", uppercase: "X", lowercase: "x", word: "Xylophone", emoji: "🎶",
                   color: .red, tracingPoints: Self.tracingX),
        LetterItem(id: "Y", uppercase: "Y", lowercase: "y", word: "Yarn", emoji: "🧶",
                   color: .pink, tracingPoints: Self.tracingY),
        LetterItem(id: "Z", uppercase: "Z", lowercase: "z", word: "Zebra", emoji: "🦓",
                   color: .gray, tracingPoints: Self.tracingZ),
    ]

    /// Look up a letter by its ID
    static func letter(for id: String) -> LetterItem? {
        letters.first { $0.id == id.uppercased() }
    }

    // MARK: - Simplified Tracing Points (normalized 0..1)
    // These define guide paths for each letter within a unit square.
    // The TracingView renders the guide letter at 70% of canvas size, centered,
    // so the letter occupies approximately x: 0.15–0.85, y: 0.22–0.78.
    // All tracing points are calibrated to match that rendered region.

    static let tracingA: [CGPoint] = [
        CGPoint(x: 0.15, y: 0.78), CGPoint(x: 0.50, y: 0.22), CGPoint(x: 0.85, y: 0.78),
        CGPoint(x: 0.32, y: 0.56), CGPoint(x: 0.68, y: 0.56),
    ]
    static let tracingB: [CGPoint] = [
        CGPoint(x: 0.25, y: 0.22), CGPoint(x: 0.25, y: 0.78),
        CGPoint(x: 0.25, y: 0.22), CGPoint(x: 0.60, y: 0.22), CGPoint(x: 0.68, y: 0.37),
        CGPoint(x: 0.60, y: 0.50), CGPoint(x: 0.25, y: 0.50),
        CGPoint(x: 0.60, y: 0.50), CGPoint(x: 0.70, y: 0.63), CGPoint(x: 0.60, y: 0.78),
        CGPoint(x: 0.25, y: 0.78),
    ]
    static let tracingC: [CGPoint] = [
        CGPoint(x: 0.75, y: 0.30), CGPoint(x: 0.50, y: 0.22), CGPoint(x: 0.28, y: 0.35),
        CGPoint(x: 0.28, y: 0.65), CGPoint(x: 0.50, y: 0.78), CGPoint(x: 0.75, y: 0.70),
    ]
    static let tracingD: [CGPoint] = [
        CGPoint(x: 0.25, y: 0.22), CGPoint(x: 0.25, y: 0.78),
        CGPoint(x: 0.25, y: 0.22), CGPoint(x: 0.55, y: 0.22), CGPoint(x: 0.75, y: 0.38),
        CGPoint(x: 0.75, y: 0.62), CGPoint(x: 0.55, y: 0.78), CGPoint(x: 0.25, y: 0.78),
    ]
    static let tracingE: [CGPoint] = [
        CGPoint(x: 0.72, y: 0.22), CGPoint(x: 0.25, y: 0.22), CGPoint(x: 0.25, y: 0.50),
        CGPoint(x: 0.65, y: 0.50), CGPoint(x: 0.25, y: 0.50), CGPoint(x: 0.25, y: 0.78),
        CGPoint(x: 0.72, y: 0.78),
    ]
    static let tracingF: [CGPoint] = [
        CGPoint(x: 0.72, y: 0.22), CGPoint(x: 0.25, y: 0.22), CGPoint(x: 0.25, y: 0.50),
        CGPoint(x: 0.60, y: 0.50), CGPoint(x: 0.25, y: 0.50), CGPoint(x: 0.25, y: 0.78),
    ]
    static let tracingG: [CGPoint] = [
        CGPoint(x: 0.75, y: 0.30), CGPoint(x: 0.50, y: 0.22), CGPoint(x: 0.28, y: 0.35),
        CGPoint(x: 0.28, y: 0.65), CGPoint(x: 0.50, y: 0.78), CGPoint(x: 0.75, y: 0.65),
        CGPoint(x: 0.75, y: 0.50), CGPoint(x: 0.55, y: 0.50),
    ]
    static let tracingH: [CGPoint] = [
        CGPoint(x: 0.22, y: 0.22), CGPoint(x: 0.22, y: 0.78),
        CGPoint(x: 0.22, y: 0.50), CGPoint(x: 0.78, y: 0.50),
        CGPoint(x: 0.78, y: 0.22), CGPoint(x: 0.78, y: 0.78),
    ]
    static let tracingI: [CGPoint] = [
        CGPoint(x: 0.33, y: 0.22), CGPoint(x: 0.67, y: 0.22),
        CGPoint(x: 0.50, y: 0.22), CGPoint(x: 0.50, y: 0.78),
        CGPoint(x: 0.33, y: 0.78), CGPoint(x: 0.67, y: 0.78),
    ]
    static let tracingJ: [CGPoint] = [
        CGPoint(x: 0.33, y: 0.22), CGPoint(x: 0.67, y: 0.22),
        CGPoint(x: 0.58, y: 0.22), CGPoint(x: 0.58, y: 0.65),
        CGPoint(x: 0.48, y: 0.78), CGPoint(x: 0.33, y: 0.70),
    ]
    static let tracingK: [CGPoint] = [
        CGPoint(x: 0.22, y: 0.22), CGPoint(x: 0.22, y: 0.78),
        CGPoint(x: 0.75, y: 0.22), CGPoint(x: 0.22, y: 0.50),
        CGPoint(x: 0.75, y: 0.78),
    ]
    static let tracingL: [CGPoint] = [
        CGPoint(x: 0.25, y: 0.22), CGPoint(x: 0.25, y: 0.78), CGPoint(x: 0.75, y: 0.78),
    ]
    static let tracingM: [CGPoint] = [
        CGPoint(x: 0.13, y: 0.78), CGPoint(x: 0.13, y: 0.22), CGPoint(x: 0.50, y: 0.55),
        CGPoint(x: 0.87, y: 0.22), CGPoint(x: 0.87, y: 0.78),
    ]
    static let tracingN: [CGPoint] = [
        CGPoint(x: 0.22, y: 0.78), CGPoint(x: 0.22, y: 0.22), CGPoint(x: 0.78, y: 0.78),
        CGPoint(x: 0.78, y: 0.22),
    ]
    static let tracingO: [CGPoint] = [
        CGPoint(x: 0.50, y: 0.22), CGPoint(x: 0.25, y: 0.35), CGPoint(x: 0.25, y: 0.65),
        CGPoint(x: 0.50, y: 0.78), CGPoint(x: 0.75, y: 0.65), CGPoint(x: 0.75, y: 0.35),
        CGPoint(x: 0.50, y: 0.22),
    ]
    static let tracingP: [CGPoint] = [
        CGPoint(x: 0.25, y: 0.78), CGPoint(x: 0.25, y: 0.22), CGPoint(x: 0.62, y: 0.22),
        CGPoint(x: 0.72, y: 0.36), CGPoint(x: 0.62, y: 0.50), CGPoint(x: 0.25, y: 0.50),
    ]
    static let tracingQ: [CGPoint] = [
        CGPoint(x: 0.50, y: 0.22), CGPoint(x: 0.25, y: 0.35), CGPoint(x: 0.25, y: 0.65),
        CGPoint(x: 0.50, y: 0.78), CGPoint(x: 0.75, y: 0.65), CGPoint(x: 0.75, y: 0.35),
        CGPoint(x: 0.50, y: 0.22), CGPoint(x: 0.62, y: 0.70), CGPoint(x: 0.82, y: 0.82),
    ]
    static let tracingR: [CGPoint] = [
        CGPoint(x: 0.25, y: 0.78), CGPoint(x: 0.25, y: 0.22), CGPoint(x: 0.62, y: 0.22),
        CGPoint(x: 0.72, y: 0.36), CGPoint(x: 0.62, y: 0.50), CGPoint(x: 0.25, y: 0.50),
        CGPoint(x: 0.48, y: 0.50), CGPoint(x: 0.75, y: 0.78),
    ]
    static let tracingS: [CGPoint] = [
        CGPoint(x: 0.72, y: 0.30), CGPoint(x: 0.50, y: 0.22), CGPoint(x: 0.28, y: 0.30),
        CGPoint(x: 0.28, y: 0.42), CGPoint(x: 0.50, y: 0.50), CGPoint(x: 0.72, y: 0.58),
        CGPoint(x: 0.72, y: 0.70), CGPoint(x: 0.50, y: 0.78), CGPoint(x: 0.28, y: 0.70),
    ]
    static let tracingT: [CGPoint] = [
        CGPoint(x: 0.15, y: 0.22), CGPoint(x: 0.85, y: 0.22),
        CGPoint(x: 0.50, y: 0.22), CGPoint(x: 0.50, y: 0.78),
    ]
    static let tracingU: [CGPoint] = [
        CGPoint(x: 0.22, y: 0.22), CGPoint(x: 0.22, y: 0.65), CGPoint(x: 0.50, y: 0.78),
        CGPoint(x: 0.78, y: 0.65), CGPoint(x: 0.78, y: 0.22),
    ]
    static let tracingV: [CGPoint] = [
        CGPoint(x: 0.15, y: 0.22), CGPoint(x: 0.50, y: 0.78), CGPoint(x: 0.85, y: 0.22),
    ]
    static let tracingW: [CGPoint] = [
        CGPoint(x: 0.08, y: 0.22), CGPoint(x: 0.28, y: 0.78), CGPoint(x: 0.50, y: 0.40),
        CGPoint(x: 0.72, y: 0.78), CGPoint(x: 0.92, y: 0.22),
    ]
    static let tracingX: [CGPoint] = [
        CGPoint(x: 0.20, y: 0.22), CGPoint(x: 0.80, y: 0.78),
        CGPoint(x: 0.80, y: 0.22), CGPoint(x: 0.20, y: 0.78),
    ]
    static let tracingY: [CGPoint] = [
        CGPoint(x: 0.20, y: 0.22), CGPoint(x: 0.50, y: 0.50),
        CGPoint(x: 0.80, y: 0.22), CGPoint(x: 0.50, y: 0.50),
        CGPoint(x: 0.50, y: 0.78),
    ]
    static let tracingZ: [CGPoint] = [
        CGPoint(x: 0.22, y: 0.22), CGPoint(x: 0.78, y: 0.22), CGPoint(x: 0.22, y: 0.78),
        CGPoint(x: 0.78, y: 0.78),
    ]

    /// Simple 3-4 letter words for the puzzle game, using only common letters
    static let puzzleWords: [(word: String, emoji: String)] = [
        ("CAT", "🐱"), ("DOG", "🐶"), ("SUN", "☀️"), ("HAT", "🎩"),
        ("BEE", "🐝"), ("CUP", "🍵"), ("PIG", "🐷"), ("BUS", "🚌"),
        ("RED", "🔴"), ("BIG", "🏔️"), ("FAN", "💨"), ("JAM", "🫙"),
        ("MAP", "🗺️"), ("NET", "🥅"), ("PEN", "🖊️"), ("RUN", "🏃"),
    ]
}
