import Foundation

struct FocusSession: Codable {
    var blockedDomains: [String]
    var totalSeconds: Int
    var remainingSeconds: Int
    var startDate: Date

    private static let storageKey = "FocusApp.ActiveSession"

    func persist() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }

    static func restore() -> FocusSession? {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              var session = try? JSONDecoder().decode(FocusSession.self, from: data) else {
            return nil
        }
        // Adjust remaining time based on elapsed time since last save
        let elapsed = Int(Date().timeIntervalSince(session.startDate))
        let originalElapsed = session.totalSeconds - session.remainingSeconds
        let totalElapsed = max(elapsed, originalElapsed)
        session.remainingSeconds = max(0, session.totalSeconds - totalElapsed)
        return session
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }

    var formattedTimeRemaining: String {
        let hours = remainingSeconds / 3600
        let minutes = (remainingSeconds % 3600) / 60
        let seconds = remainingSeconds % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
