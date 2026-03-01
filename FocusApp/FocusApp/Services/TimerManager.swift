import Foundation
import Combine

class TimerManager: ObservableObject {
    @Published var remainingSeconds: Int = 0
    @Published var isRunning = false

    var onTimerExpired: (() -> Void)?
    var onTick: ((Int) -> Void)?

    private var timer: AnyCancellable?

    func start(seconds: Int) {
        remainingSeconds = seconds
        isRunning = true
        timer?.cancel()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    func stop() {
        timer?.cancel()
        timer = nil
        isRunning = false
        remainingSeconds = 0
    }

    func addTime(seconds: Int) {
        remainingSeconds += seconds
    }

    private func tick() {
        guard remainingSeconds > 0 else {
            stop()
            onTimerExpired?()
            return
        }
        remainingSeconds -= 1
        onTick?(remainingSeconds)

        if remainingSeconds <= 0 {
            stop()
            onTimerExpired?()
        }
    }
}
