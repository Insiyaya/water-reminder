import Foundation

class ReminderScheduler {
    private var timer: Timer?
    private var intervalSeconds: TimeInterval
    private(set) var nextReminderDate: Date?
    private let callback: () -> Void

    init(intervalMinutes: Int = 25, callback: @escaping () -> Void) {
        self.intervalSeconds = TimeInterval(intervalMinutes * 60)
        self.callback = callback
    }

    func start() {
        scheduleNext()
    }

    func reset() {
        timer?.invalidate()
        scheduleNext()
    }

    func snooze(minutes: Int) {
        timer?.invalidate()
        let snoozeInterval = TimeInterval(minutes * 60)
        nextReminderDate = Date().addingTimeInterval(snoozeInterval)
        timer = Timer.scheduledTimer(withTimeInterval: snoozeInterval, repeats: false) { [weak self] _ in
            self?.callback()
            self?.scheduleNext()
        }
    }

    func setInterval(minutes: Int) {
        intervalSeconds = TimeInterval(minutes * 60)
        timer?.invalidate()
        scheduleNext()
    }

    private func scheduleNext() {
        timer?.invalidate()
        nextReminderDate = Date().addingTimeInterval(intervalSeconds)
        timer = Timer.scheduledTimer(withTimeInterval: intervalSeconds, repeats: false) { [weak self] _ in
            self?.callback()
            self?.scheduleNext()
        }
    }
}
