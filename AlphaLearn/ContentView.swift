import SwiftUI

// MARK: - Content View

/// Root view that wraps HomeView. This is the entry point for the app UI.
struct ContentView: View {
    @EnvironmentObject var progress: ProgressModel

    var body: some View {
        HomeView()
            .environmentObject(progress)
    }
}
