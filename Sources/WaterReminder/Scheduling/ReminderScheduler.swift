import Foundation

final class ReminderScheduler {
    private var timer: Timer?
    private var intervalSeconds: TimeInterval
    private(set) var nextReminderDate: Date?
    private let onFire: () -> Void

    init(intervalMinutes: Int = 25, onFire: @escaping () -> Void) {
        self.intervalSeconds = TimeInterval(intervalMinutes * 60)
        self.onFire = onFire
    }

    // MARK: - Control

    func start()  { scheduleNext() }

    func reset()  { timer?.invalidate(); scheduleNext() }

    func snooze(minutes: Int) {
        timer?.invalidate()
        let delay = TimeInterval(minutes * 60)
        nextReminderDate = Date().addingTimeInterval(delay)
        timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            self?.onFire()
            self?.scheduleNext()
        }
    }

    func setInterval(minutes: Int) {
        intervalSeconds = TimeInterval(minutes * 60)
        timer?.invalidate()
        scheduleNext()
    }

    // MARK: - Private

    private func scheduleNext() {
        timer?.invalidate()
        nextReminderDate = Date().addingTimeInterval(intervalSeconds)
        timer = Timer.scheduledTimer(withTimeInterval: intervalSeconds, repeats: false) { [weak self] _ in
            self?.onFire()
            self?.scheduleNext()
        }
    }
}
