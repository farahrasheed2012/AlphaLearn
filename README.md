# AlphaLearn - Interactive Alphabet Learning App

An interactive, colorful SwiftUI app designed to help soon-to-be kindergarteners learn to read, recognize, and write the alphabet through games and play.

## Features

### 1. Alphabet Learning & Tracing
- **Letter Explorer**: Browse all 26 letters with uppercase/lowercase display
- **Audio Pronunciation**: Tap to hear the letter name, phonetic sound, and associated word (uses text-to-speech)
- **Letter Tracing**: Trace letters with your finger on-screen with:
  - Guide dots showing where to draw
  - Sparkle effects following your finger
  - Progress bar tracking coverage
  - Celebration animations on success

### 2. Mini-Games

| Game | Description |
|------|-------------|
| **Letter Matching** | Match letters to their corresponding pictures across 3 rounds |
| **Find the Letter** | Spot the target letter in a 3x3 grid with audio cues |
| **Alphabet Puzzle** | Tap scrambled letters to spell simple words like CAT, DOG, SUN |
| **Bubble Pop** | Pop floating bubbles containing the target letter |

### 3. Progress & Rewards
- **Stars**: Earn stars for every activity completed
- **14 Badges**: Unlock achievements like "Alphabet Champion", "Master Writer", "Game Master"
- **Virtual Sticker Board**: Display all earned badges
- **Positive Reinforcement**: Cheerful messages ("You did it!", "Great job!") with celebrations

### 4. Parent Dashboard
- View overall learning progress
- Track letters viewed vs. traced
- See game completion stats per game type
- Monitor daily practice streak
- Option to reset all progress

## Technical Details

- **Platform**: iOS 16+ (iPhone and iPad)
- **Framework**: SwiftUI
- **Audio**: AVSpeechSynthesizer (no audio files needed) + system sounds
- **Persistence**: UserDefaults (via Codable ProgressModel)
- **No external dependencies**

## Project Structure

```
AlphaLearn/
├── AlphaLearnApp.swift          # App entry point
├── ContentView.swift            # Root view wrapper
├── Models/
│   ├── LetterModel.swift        # Letter data + tracing paths for all 26 letters
│   ├── ProgressModel.swift      # Progress tracking + badge logic
│   └── RewardModel.swift        # Badge definitions + cheer messages
├── Services/
│   ├── AudioService.swift       # Text-to-speech + sound effects + haptics
│   └── ProgressStore.swift      # UserDefaults persistence
├── Components/
│   ├── AnimatedButton.swift     # Kid-friendly buttons, letter tiles, bouncing emoji
│   └── ConfettiView.swift       # Confetti, star burst, sparkle effects
├── Views/
│   ├── HomeView.swift           # Main menu with navigation cards
│   ├── AlphabetView.swift       # Letter grid browser
│   ├── LetterDetailView.swift   # Individual letter with audio & navigation
│   ├── TracingView.swift        # Full-screen letter tracing canvas
│   ├── Games/
│   │   ├── GamesMenuView.swift       # Game selection menu
│   │   ├── LetterMatchingGame.swift   # Match letters to pictures
│   │   ├── FindTheLetterGame.swift    # Find target letter in grid
│   │   ├── AlphabetPuzzleGame.swift   # Spell words by tapping letters
│   │   └── BubblePopGame.swift        # Pop bubbles with correct letter
│   ├── Rewards/
│   │   └── RewardsView.swift    # Sticker board + badge details
│   └── ParentDashboard/
│       └── ParentDashboardView.swift  # Progress stats for parents
└── Assets.xcassets/
    ├── AppIcon.appiconset/
    └── AccentColor.colorset/
```

## How to Run

1. **Open in Xcode**: Double-click `AlphaLearn.xcodeproj` to open the project
2. **Select a Simulator**: Choose an iPhone or iPad simulator (iOS 16+)
3. **Build & Run**: Press `Cmd + R` to build and run the app
4. **No setup required**: The app uses emoji for images and text-to-speech for audio — no additional assets needed

## Placeholder Assets

The app uses system-provided resources as placeholders:
- **Images**: Emoji characters for each letter (🍎, ⚽, 🐱, etc.)
- **Audio**: `AVSpeechSynthesizer` for letter/word pronunciation
- **Sound Effects**: System sounds (`AudioServicesPlaySystemSound`) for feedback
- **Haptics**: UIKit haptic feedback for touch interactions

To add custom assets later:
- Replace emoji with actual images in `Assets.xcassets`
- Add audio files and update `AudioService.swift` to use `AVAudioPlayer`

## Customization & Expansion

Each mini-game is self-contained in its own file, making it easy to:
- Add new games (follow the pattern in the `Games/` folder)
- Adjust difficulty (change `totalRounds`, grid sizes, timer durations)
- Add more puzzle words in `AlphabetData.puzzleWords`
- Create new badges in `BadgeCatalog.all`
- Customize colors per letter in `AlphabetData.letters`
