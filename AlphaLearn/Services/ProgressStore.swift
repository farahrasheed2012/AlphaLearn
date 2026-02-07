import Foundation

// MARK: - Progress Store

/// Persists the child's progress data to UserDefaults
class ProgressStore {
    static let shared = ProgressStore()
    private let key = "alphalearn_progress"

    private init() {}

    /// Save progress to UserDefaults
    func save(_ progress: ProgressModel) {
        if let data = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    /// Load progress from UserDefaults, or return a new model
    func load() -> ProgressModel {
        guard let data = UserDefaults.standard.data(forKey: key),
              let progress = try? JSONDecoder().decode(ProgressModel.self, from: data) else {
            return ProgressModel()
        }
        return progress
    }

    /// Reset all progress (for parental controls)
    func reset() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
