import SwiftUI
import Combine
import UserNotifications

@main
struct FocusApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
                .environmentObject(appState)
        } label: {
            Image(systemName: appState.isFocusActive ? "moon.fill" : "moon")
        }
        .menuBarExtraStyle(.window)
    }
}

@MainActor
class AppState: ObservableObject {
    @Published var settings = AppSettings()
    @Published var session: FocusSession?
    @Published var isFocusActive = false

    let hostsManager = HostsFileManager()
    let timerManager = TimerManager()
    let phraseGenerator = PhraseGenerator()

    private var timerCancellable: AnyCancellable?

    init() {
        // Forward timer's objectWillChange to AppState so views update
        timerCancellable = timerManager.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
        timerManager.onTimerExpired = { [weak self] in
            self?.stopFocus()
        }
        timerManager.onTick = { [weak self] remaining in
            self?.session?.remainingSeconds = remaining
            self?.session?.persist()
        }
        restoreSession()
    }

    func restoreSession() {
        if let restored = FocusSession.restore() {
            if restored.remainingSeconds > 0 {
                session = restored
                isFocusActive = true
                timerManager.start(seconds: restored.remainingSeconds)
            } else {
                stopFocus()
            }
        }
    }

    func startFocus(minutes: Int) {
        let blockedDomains = settings.blockedDomains
        guard !blockedDomains.isEmpty else { return }

        let totalSeconds = minutes * 60
        session = FocusSession(
            blockedDomains: blockedDomains,
            totalSeconds: totalSeconds,
            remainingSeconds: totalSeconds,
            startDate: Date()
        )
        session?.persist()
        isFocusActive = true

        hostsManager.blockDomains(blockedDomains) { [weak self] success in
            if !success {
                self?.session = nil
                self?.isFocusActive = false
                FocusSession.clear()
            }
        }
        timerManager.start(seconds: totalSeconds)
    }

    func addTime(minutes: Int) {
        guard var currentSession = session else { return }
        let additionalSeconds = minutes * 60
        currentSession.remainingSeconds += additionalSeconds
        currentSession.totalSeconds += additionalSeconds
        session = currentSession
        session?.persist()
        timerManager.addTime(seconds: additionalSeconds)
    }

    func stopFocus() {
        guard let currentSession = session else { return }
        timerManager.stop()
        hostsManager.unblockDomains { _ in }
        session = nil
        isFocusActive = false
        FocusSession.clear()

        sendNotification(title: "Focus Session Ended", body: "Your \(currentSession.totalSeconds / 60)-minute focus session is complete.")
    }

    func attemptEarlyStop(typedPhrase: String, challenge: String) -> Bool {
        if typedPhrase == challenge {
            stopFocus()
            return true
        }
        return false
    }

    private func sendNotification(title: String, body: String) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { _, _ in }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        center.add(request)
    }
}
