import SwiftUI

// MARK: - Tracing View

/// Full-screen letter tracing canvas with visual and audio feedback.
/// Shows the letter outline as a guide; child traces with their finger.
struct TracingView: View {
    @EnvironmentObject var progress: ProgressModel
    @Environment(\.dismiss) var dismiss
    let letter: LetterItem

    @State private var drawnPaths: [[CGPoint]] = []
    @State private var currentPath: [CGPoint] = []
    @State private var showSuccess = false
    @State private var showConfetti = false
    @State private var guideDotIndex = 0
    @State private var traceProgress: CGFloat = 0
    @State private var message = "Trace the letter with your finger!"

    private let audio = AudioService.shared

    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 16) {
                // Header
                header

                // Feedback message
                Text(message)
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .animation(.easeInOut, value: message)

                // Tracing canvas
                tracingCanvas
                    .frame(maxWidth: 400, maxHeight: 400)
                    .padding()

                // Progress indicator
                ProgressView(value: traceProgress)
                    .tint(letter.color)
                    .padding(.horizontal, 40)

                // Action buttons
                HStack(spacing: 20) {
                    KidButton(title: "Clear", emoji: "🗑️", color: .red) {
                        clearCanvas()
                    }

                    KidButton(title: "Done!", emoji: "✅", color: .green) {
                        checkTracing()
                    }
                }

                Spacer()
            }

            // Confetti celebration
            ConfettiView(isActive: $showConfetti)
        }
        .onAppear {
            audio.speakInstruction("Trace the letter \(letter.uppercase) with your finger!")
        }
    }

    // MARK: - Header

    private var header: some View {
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

            // Letter reference
            Text(letter.emoji)
                .font(.title)
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }

    // MARK: - Tracing Canvas

    private var tracingCanvas: some View {
        GeometryReader { geo in
            ZStack {
                // Light background
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(letter.color.opacity(0.3), lineWidth: 2)
                    )

                // Guide letter (faint)
                Text(letter.uppercase)
                    .font(.system(size: min(geo.size.width, geo.size.height) * 0.7,
                                  weight: .bold, design: .rounded))
                    .foregroundColor(letter.color.opacity(0.15))

                // Guide dots
                guideDots(in: geo.size)

                // Drawn paths (previous strokes)
                ForEach(drawnPaths.indices, id: \.self) { i in
                    StrokePath(points: drawnPaths[i])
                        .stroke(letter.color, style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
                }

                // Current stroke being drawn
                StrokePath(points: currentPath)
                    .stroke(letter.color.opacity(0.8),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))

                // Sparkle at current touch point
                if let last = currentPath.last {
                    Text("✨")
                        .font(.caption)
                        .position(last)
                        .animation(.none, value: currentPath.count)
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let point = value.location
                        // Clamp to canvas bounds
                        let clamped = CGPoint(
                            x: max(0, min(geo.size.width, point.x)),
                            y: max(0, min(geo.size.height, point.y))
                        )
                        currentPath.append(clamped)
                        updateProgress(canvasSize: geo.size)
                        audio.hapticLight()
                    }
                    .onEnded { _ in
                        if !currentPath.isEmpty {
                            drawnPaths.append(currentPath)
                            currentPath = []
                        }
                    }
            )
        }
        .aspectRatio(1, contentMode: .fit)
    }

    // MARK: - Guide Dots

    private func guideDots(in size: CGSize) -> some View {
        ForEach(letter.tracingPoints.indices, id: \.self) { i in
            let point = letter.tracingPoints[i]
            let pos = CGPoint(x: point.x * size.width, y: point.y * size.height)

            Circle()
                .fill(letter.color.opacity(i == 0 ? 0.6 : 0.25))
                .frame(width: i == 0 ? 20 : 14, height: i == 0 ? 20 : 14)
                .overlay(
                    i == 0
                    ? Circle().stroke(letter.color, lineWidth: 2)
                    : nil
                )
                .position(pos)

            if i == 0 {
                Text("Start")
                    .font(.caption2.bold())
                    .foregroundColor(letter.color)
                    .position(x: pos.x, y: pos.y - 18)
            }
        }
    }

    // MARK: - Logic

    private func updateProgress(canvasSize: CGSize) {
        let totalPoints = drawnPaths.flatMap { $0 } + currentPath
        guard !totalPoints.isEmpty else { traceProgress = 0; return }

        // Calculate coverage: how many guide points are near a drawn point
        var hitCount = 0
        for guide in letter.tracingPoints {
            let guidePos = CGPoint(x: guide.x * canvasSize.width,
                                   y: guide.y * canvasSize.height)
            let threshold: CGFloat = 35
            let hit = totalPoints.contains { p in
                hypot(p.x - guidePos.x, p.y - guidePos.y) < threshold
            }
            if hit { hitCount += 1 }
        }

        withAnimation {
            traceProgress = CGFloat(hitCount) / CGFloat(max(1, letter.tracingPoints.count))
        }
    }

    private func checkTracing() {
        if traceProgress >= 0.6 {
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
        } else {
            // Encourage to try more
            message = CheerMessages.randomEncouragement()
            audio.playTryAgain()
            audio.hapticError()
        }
    }

    private func clearCanvas() {
        drawnPaths = []
        currentPath = []
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
