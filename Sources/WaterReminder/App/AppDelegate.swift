import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let statusBar = StatusBarController()
    private var scheduler: ReminderScheduler?
    private var overlayController: OverlayWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBar.setup()
        wireCallbacks()
        startScheduler()
        startCountdownRefresh()
    }

    // MARK: - Wiring

    private func wireCallbacks() {
        statusBar.onShowNow = { [weak self] in
            self?.triggerReminder()
            self?.scheduler?.reset()
        }
        statusBar.onSnooze = { [weak self] in
            self?.scheduler?.snooze(minutes: 5)
            self?.refreshCountdown()
        }
        statusBar.onIntervalChanged = { [weak self] minutes in
            self?.scheduler?.setInterval(minutes: minutes)
            self?.refreshCountdown()
        }
    }

    // MARK: - Scheduling

    private func startScheduler() {
        scheduler = ReminderScheduler(intervalMinutes: statusBar.intervalMinutes) { [weak self] in
            DispatchQueue.main.async { self?.triggerReminder() }
        }
        scheduler?.start()
    }

    private func startCountdownRefresh() {
        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.refreshCountdown()
        }
        refreshCountdown()
    }

    private func refreshCountdown() {
        guard let date = scheduler?.nextReminderDate else { return }
        statusBar.updateCountdown(secondsRemaining: max(0, date.timeIntervalSinceNow))
    }

    // MARK: - Reminder

    private func triggerReminder() {
        let controller = OverlayWindowController()
        controller.snoozeCallback = { [weak self] in
            self?.scheduler?.snooze(minutes: 5)
            self?.refreshCountdown()
        }
        controller.showOverlay()
        overlayController = controller
    }
}
