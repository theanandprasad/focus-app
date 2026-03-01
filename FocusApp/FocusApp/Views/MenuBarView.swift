import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 0) {
            if appState.isFocusActive {
                ActiveSessionView()
            } else {
                IdleView()
            }

            Divider()
                .padding(.vertical, 4)

            Button("Quit Focus") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
            .font(.caption)
            .padding(.bottom, 8)
        }
        .frame(width: 320)
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }
}

// MARK: - Idle View (not in focus mode)

struct IdleView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedMinutes = 30

    private let durations = [15, 30, 60, 120]

    var body: some View {
        VStack(spacing: 12) {
            Text("Focus Mode")
                .font(.headline)

            DomainListView()

            Divider()

            // Timer duration picker
            VStack(alignment: .leading, spacing: 6) {
                Text("Duration")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack(spacing: 8) {
                    ForEach(durations, id: \.self) { mins in
                        Button(durationLabel(mins)) {
                            selectedMinutes = mins
                        }
                        .buttonStyle(.bordered)
                        .tint(selectedMinutes == mins ? .accentColor : .secondary)
                    }
                }
            }

            Button(action: { appState.startFocus(minutes: selectedMinutes) }) {
                Text("Start Focus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(appState.settings.blockedDomains.isEmpty)
            .controlSize(.large)
            .padding(.top, 4)
        }
        .padding(.bottom, 8)
    }

    private func durationLabel(_ minutes: Int) -> String {
        if minutes >= 60 {
            return "\(minutes / 60)h"
        }
        return "\(minutes)m"
    }
}

// MARK: - Active Session View

struct ActiveSessionView: View {
    @EnvironmentObject var appState: AppState
    @State private var showDisableChallenge = false

    var body: some View {
        VStack(spacing: 12) {
            Text("Focus Active")
                .font(.headline)
                .foregroundColor(.red)

            TimerView()

            // Blocked domains (read-only)
            if let session = appState.session {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Blocking \(session.blockedDomains.count) sites")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    ScrollView {
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(session.blockedDomains, id: \.self) { domain in
                                Text(domain)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxHeight: 60)
                }
            }

            Divider()

            // Add time buttons
            HStack(spacing: 8) {
                Text("Add Time:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Button("+15m") { appState.addTime(minutes: 15) }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                Button("+30m") { appState.addTime(minutes: 30) }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                Button("+1h") { appState.addTime(minutes: 60) }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
            }

            Button("Emergency Stop") {
                showDisableChallenge = true
            }
            .buttonStyle(.plain)
            .foregroundColor(.orange)
            .font(.caption)
            .padding(.top, 4)
        }
        .padding(.bottom, 8)
        .sheet(isPresented: $showDisableChallenge) {
            DisableFocusView(isPresented: $showDisableChallenge)
                .environmentObject(appState)
        }
    }
}
