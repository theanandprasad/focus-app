import SwiftUI

struct TimerView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 4) {
            Text(appState.timerManager.remainingSeconds.formattedTime)
                .font(.system(size: 48, weight: .light, design: .monospaced))
                .foregroundColor(.primary)

            Text("remaining")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

extension Int {
    var formattedTime: String {
        let hours = self / 3600
        let minutes = (self % 3600) / 60
        let seconds = self % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
