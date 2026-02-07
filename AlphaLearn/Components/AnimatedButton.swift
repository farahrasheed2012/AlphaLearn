import SwiftUI

// MARK: - Kid-Friendly Animated Button

/// Large, colorful, bouncy button designed for small fingers
struct KidButton: View {
    let title: String
    let emoji: String
    let color: Color
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            isPressed = true
            AudioService.shared.playTap()
            AudioService.shared.hapticLight()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isPressed = false
                action()
            }
        }) {
            HStack(spacing: 12) {
                Text(emoji)
                    .font(.title)
                Text(title)
                    .font(.title2.bold())
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(color.gradient)
                    .shadow(color: color.opacity(0.5), radius: 8, y: 4)
            )
        }
        .scaleEffect(isPressed ? 0.92 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.5), value: isPressed)
    }
}

// MARK: - Circle Icon Button

/// Round button with emoji icon — used in game menus
struct CircleButton: View {
    let emoji: String
    let label: String
    let color: Color
    let size: CGFloat
    let action: () -> Void

    @State private var isPressed = false

    init(emoji: String, label: String, color: Color, size: CGFloat = 90, action: @escaping () -> Void) {
        self.emoji = emoji
        self.label = label
        self.color = color
        self.size = size
        self.action = action
    }

    var body: some View {
        Button(action: {
            isPressed = true
            AudioService.shared.playTap()
            AudioService.shared.hapticLight()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isPressed = false
                action()
            }
        }) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.gradient)
                        .frame(width: size, height: size)
                        .shadow(color: color.opacity(0.4), radius: 6, y: 3)
                    Text(emoji)
                        .font(.system(size: size * 0.45))
                }
                Text(label)
                    .font(.caption.bold())
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .frame(width: size + 20)
            }
        }
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.5), value: isPressed)
    }
}

// MARK: - Letter Tile

/// A colorful tile showing a letter — used in games and alphabet grid
struct LetterTile: View {
    let letter: String
    let color: Color
    let size: CGFloat

    init(letter: String, color: Color = .blue, size: CGFloat = 70) {
        self.letter = letter
        self.color = color
        self.size = size
    }

    var body: some View {
        Text(letter)
            .font(.system(size: size * 0.55, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .frame(width: size, height: size)
            .background(
                RoundedRectangle(cornerRadius: size * 0.2)
                    .fill(color.gradient)
                    .shadow(color: color.opacity(0.4), radius: 4, y: 2)
            )
    }
}

// MARK: - Bouncing Emoji

/// An emoji that bounces continuously — decorative
struct BouncingEmoji: View {
    let emoji: String
    let size: CGFloat
    @State private var bounce = false

    init(_ emoji: String, size: CGFloat = 40) {
        self.emoji = emoji
        self.size = size
    }

    var body: some View {
        Text(emoji)
            .font(.system(size: size))
            .offset(y: bounce ? -8 : 0)
            .animation(
                .easeInOut(duration: 0.6)
                .repeatForever(autoreverses: true),
                value: bounce
            )
            .onAppear { bounce = true }
    }
}
