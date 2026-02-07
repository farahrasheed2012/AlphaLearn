import SwiftUI

// MARK: - Confetti Particle

/// A single confetti particle with random properties
struct ConfettiParticle: Identifiable {
    let id = UUID()
    let emoji: String
    let x: CGFloat
    let size: CGFloat
    let duration: Double
    let delay: Double
    let rotation: Double

    static func random() -> ConfettiParticle {
        let emojis = ["🎉", "⭐", "🌟", "✨", "💫", "🎊", "🎈", "🌈", "💖", "🦋"]
        return ConfettiParticle(
            emoji: emojis.randomElement()!,
            x: CGFloat.random(in: 0...1),
            size: CGFloat.random(in: 20...40),
            duration: Double.random(in: 1.5...3.0),
            delay: Double.random(in: 0...0.5),
            rotation: Double.random(in: -180...180)
        )
    }
}

// MARK: - Confetti Overlay

/// Full-screen confetti celebration animation
struct ConfettiView: View {
    @Binding var isActive: Bool
    @State private var particles: [ConfettiParticle] = []

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { p in
                    ConfettiPiece(particle: p, size: geo.size)
                }
            }
        }
        .allowsHitTesting(false)
        .onChange(of: isActive) { newValue in
            if newValue {
                particles = (0..<30).map { _ in ConfettiParticle.random() }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                    isActive = false
                    particles = []
                }
            }
        }
    }
}

// MARK: - Single Confetti Piece

struct ConfettiPiece: View {
    let particle: ConfettiParticle
    let size: CGSize
    @State private var animate = false

    var body: some View {
        Text(particle.emoji)
            .font(.system(size: particle.size))
            .position(
                x: particle.x * size.width,
                y: animate ? size.height + 50 : -50
            )
            .rotationEffect(.degrees(animate ? particle.rotation : 0))
            .opacity(animate ? 0 : 1)
            .onAppear {
                withAnimation(
                    .easeIn(duration: particle.duration)
                    .delay(particle.delay)
                ) {
                    animate = true
                }
            }
    }
}

// MARK: - Star Burst Effect

/// Animated stars bursting outward from center — used for small celebrations
struct StarBurstView: View {
    @Binding var isActive: Bool
    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 1
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { i in
                Text("⭐")
                    .font(.title)
                    .offset(
                        x: isActive ? cos(Double(i) * .pi / 4) * 60 : 0,
                        y: isActive ? sin(Double(i) * .pi / 4) * 60 : 0
                    )
            }
        }
        .scaleEffect(scale)
        .opacity(opacity)
        .rotationEffect(.degrees(rotation))
        .onChange(of: isActive) { newValue in
            if newValue {
                scale = 0.3
                opacity = 1
                rotation = 0
                withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                    scale = 1.2
                    rotation = 45
                }
                withAnimation(.easeOut(duration: 0.8).delay(0.5)) {
                    opacity = 0
                    scale = 1.5
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    isActive = false
                }
            }
        }
    }
}

// MARK: - Sparkle Effect

/// Small sparkle particles around a view
struct SparkleModifier: ViewModifier {
    let isActive: Bool
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content.overlay(
            ZStack {
                if isActive {
                    ForEach(0..<6, id: \.self) { i in
                        Text("✨")
                            .font(.caption)
                            .offset(
                                x: cos(Double(i) * .pi / 3 + phase) * 30,
                                y: sin(Double(i) * .pi / 3 + phase) * 30
                            )
                            .opacity(0.8)
                    }
                }
            }
            .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: phase)
            .onAppear { phase = .pi * 2 }
        )
    }
}

extension View {
    func sparkle(when active: Bool) -> some View {
        modifier(SparkleModifier(isActive: active))
    }
}
