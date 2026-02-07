import SwiftUI

// MARK: - App Entry Point

/// AlphaLearn: An interactive alphabet learning app for kindergarteners
@main
struct AlphaLearnApp: App {
    /// Shared progress model loaded from persistent storage
    @StateObject private var progress = ProgressStore.shared.load()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(progress)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    // Auto-save progress when app goes to background
                    ProgressStore.shared.save(progress)
                }
        }
    }
}
