import SwiftUI

// MARK: - Tracing View

/// Full-screen letter tracing canvas with visual and audio feedback.
/// Shows the letter outline as a guide; child traces with their finger.
struct TracingView: View {
    @EnvironmentObject var progress: ProgressModel
    @Environment(\.dismiss) var dismiss
    let letter: LetterItem

    // Drawing state
    @State private var drawnPaths: [[CGPoint]] = []
    @State private var currentPath: [CGPoint] = []

    // Progress tracking — which guide points have been hit
    @State private var hitGuideIndices: Set<Int> = []
    @State private var traceProgress: CGFloat = 0

    // UI state
    @State private var showConfetti = false
    @State private var showSuccess = false
    @State private var message = "Trace the letter with your finger!"
    @State private var canvasSize: CGSize = .zero

    private let audio = AudioService.shared

    /// How close (in points) a drawn point must be to a guide point to count as a hit
    private let hitRadius: CGFloat = 50
    /// Fraction of guide points that must be hit for success
    private let successThreshold: CGFloat = 0.5

    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 16) {
                // Header bar with close, title, emoji
                headerBar

                // Feedback message
                Text(message)
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .animation(.easeInOut, value: message)

                // The tracing canvas
                canvas
                    .frame(maxWidth: 400, maxHeight: 400)
                    .padding(.horizontal)

                // Progress bar
                ProgressView(value: traceProgress)
                    .tint(letter.color)
                    .padding(.horizontal, 40)
                    .animation(.easeInOut(duration: 0.2), value: traceProgress)

                // Action buttons
                HStack(spacing: 20) {
                    Button {
                        clearCanvas()
                    } label: {
                        Label("Clear", systemImage: "trash")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.red.gradient)
                                    .shadow(color: .red.opacity(0.4), radius: 6, y: 3)
                            )
                    }

                    Button {
                        checkTracing()
                    } label: {
                        Label("Done!", systemImage: "checkmark.circle.fill")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.green.gradient)
                                    .shadow(color: .green.opacity(0.4), radius: 6, y: 3)
                            )
                    }
                }
                .padding(.top, 4)

                Spacer(minLength: 20)
            }

            // Confetti celebration overlay
            ConfettiView(isActive: $showConfetti)
        }
        .onAppear {
            audio.speakInstruction("Trace the letter \(letter.uppercase) with your finger!")
        }
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text("Trace: \(letter.uppercase)")
                .font(.title2.bold())
                .foregroundColor(letter.color)

            Spacer()

            Text(letter.emoji)
                .font(.title)
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }

    // MARK: - Canvas

    private var canvas: some View {
        GeometryReader { geo in
            ZStack {
                // Canvas background
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(letter.color.opacity(0.3), lineWidth: 2)
                    )

                // Faint guide letter
                Text(letter.uppercase)
                    .font(.system(size: min(geo.size.width, geo.size.height) * 0.7,
                                  weight: .bold, design: .rounded))
                    .foregroundColor(letter.color.opacity(0.15))

                // Guide dots
                ForEach(Array(letter.tracingPoints.enumerated()), id: \.offset) { index, point in
                    let pos = CGPoint(x: point.x * geo.size.width,
                                      y: point.y * geo.size.height)
                    let isHit = hitGuideIndices.contains(index)
                    let isFirst = index == 0

                    Circle()
                        .fill(isHit ? Color.green.opacity(0.7) :
                                (isFirst ? letter.color.opacity(0.6) : letter.color.opacity(0.25)))
                        .frame(width: isFirst ? 20 : 14, height: isFirst ? 20 : 14)
                        .overlay(
                            Circle()
                                .stroke(isHit ? Color.green : letter.color, lineWidth: isFirst ? 2 : 0)
                        )
                        .position(pos)
                }

                // "Start" label on first guide dot
                if let first = letter.tracingPoints.first {
                    Text("Start")
                        .font(.caption2.bold())
                        .foregroundColor(letter.color)
                        .position(x: first.x * geo.size.width,
                                  y: first.y * geo.size.height - 18)
                }

                // Previously completed strokes
                ForEach(drawnPaths.indices, id: \.self) { i in
                    StrokePath(points: drawnPaths[i])
                        .stroke(letter.color,
                                style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
                }

                // Current in-progress stroke
                StrokePath(points: currentPath)
                    .stroke(letter.color.opacity(0.8),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))

                // Sparkle at current touch point
                if let last = currentPath.last {
                    Text("✨")
                        .font(.caption)
                        .position(last)
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        // Store canvas size for later use
                        canvasSize = geo.size

                        // Clamp the touch point to the canvas
                        let clamped = CGPoint(
                            x: max(0, min(geo.size.width, value.location.x)),
                            y: max(0, min(geo.size.height, value.location.y))
                        )
                        currentPath.append(clamped)

                        // Check if this new point hits any guide dot
                        checkNewPointHits(clamped, canvasSize: geo.size)
                    }
                    .onEnded { _ in
                        if !currentPath.isEmpty {
                            drawnPaths.append(currentPath)
                            currentPath = []
                        }
                    }
            )
            .onAppear {
                canvasSize = geo.size
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    // MARK: - Hit Detection (efficient)

    /// Only check the newest drawn point against un-hit guide points.
    /// This avoids the O(n*m) scan on every touch movement.
    private func checkNewPointHits(_ point: CGPoint, canvasSize: CGSize) {
        var newHit = false
        for (index, guide) in letter.tracingPoints.enumerated() {
            if hitGuideIndices.contains(index) { continue } // already hit

            let guidePos = CGPoint(x: guide.x * canvasSize.width,
                                   y: guide.y * canvasSize.height)
            let distance = hypot(point.x - guidePos.x, point.y - guidePos.y)

            if distance < hitRadius {
                hitGuideIndices.insert(index)
                newHit = true
            }
        }

        if newHit {
            // Update progress only when something actually changed
            let total = max(1, letter.tracingPoints.count)
            traceProgress = CGFloat(hitGuideIndices.count) / CGFloat(total)
            audio.hapticLight()
        }
    }

    // MARK: - Check / Clear / Done

    private func checkTracing() {
        if traceProgress >= successThreshold {
            // Success!
            showSuccess = true
            showConfetti = true
            message = CheerMessages.randomSuccess()
            audio.playCelebration()
            audio.hapticSuccess()
            progress.markLetterTraced(letter.id)
            ProgressStore.shared.save(progress)

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                dismiss()
            }
        } else if drawnPaths.isEmpty && currentPath.isEmpty {
            // Nothing drawn yet
            message = "Draw on the letter first! ✏️"
            audio.speakInstruction("Trace the letter with your finger first!")
        } else {
            // Not enough coverage yet — encourage
            message = CheerMessages.randomEncouragement()
            audio.playTryAgain()
            audio.hapticError()
        }
    }

    private func clearCanvas() {
        drawnPaths = []
        currentPath = []
        hitGuideIndices = []
        traceProgress = 0
        message = "Trace the letter with your finger!"
        audio.playTap()
    }
}

// MARK: - Stroke Path Shape

/// A shape that draws through a series of points
struct StrokePath: Shape {
    let points: [CGPoint]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard let first = points.first else { return path }
        path.move(to: first)
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        return path
    }
}
