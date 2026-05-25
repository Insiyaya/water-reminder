import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    var scheduler: ReminderScheduler?
    var overlayController: OverlayWindowController?
    private var nextReminderMenuItem: NSMenuItem?
    private var currentIntervalMinutes = 25
    private var intervalMenuItems: [NSMenuItem] = []

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusBar()
        scheduler = ReminderScheduler(intervalMinutes: currentIntervalMinutes) { [weak self] in
            DispatchQueue.main.async { self?.showWaterReminder() }
        }
        scheduler?.start()
        startMenuUpdateTimer()
    }

    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.title = "💧"
            button.font = NSFont.systemFont(ofSize: 15)
        }
        buildMenu()
    }

    private func buildMenu() {
        let menu = NSMenu()

        let title = NSMenuItem(title: "💧 Water Reminder", action: nil, keyEquivalent: "")
        title.isEnabled = false
        menu.addItem(title)
        menu.addItem(.separator())

        let nextItem = NSMenuItem(title: "Next reminder: calculating…", action: nil, keyEquivalent: "")
        nextItem.isEnabled = false
        self.nextReminderMenuItem = nextItem
        menu.addItem(nextItem)
        menu.addItem(.separator())

        let drinkNow = NSMenuItem(title: "💧  Hydrate Now!", action: #selector(showNow), keyEquivalent: "d")
        drinkNow.target = self
        menu.addItem(drinkNow)

        let snooze = NSMenuItem(title: "⏰  Snooze 5 minutes", action: #selector(snooze5), keyEquivalent: "")
        snooze.target = self
        menu.addItem(snooze)
        menu.addItem(.separator())

        let intervalMenu = NSMenu()
        for mins in [15, 20, 25, 30, 45, 60] {
            let item = NSMenuItem(title: "\(mins) minutes", action: #selector(setInterval(_:)), keyEquivalent: "")
            item.target = self
            item.tag = mins
            item.state = (mins == currentIntervalMinutes) ? .on : .off
            intervalMenu.addItem(item)
            intervalMenuItems.append(item)
        }
        let intervalItem = NSMenuItem(title: "⏱  Reminder Interval", action: nil, keyEquivalent: "")
        intervalItem.submenu = intervalMenu
        menu.addItem(intervalItem)

        menu.addItem(.separator())
        let quit = NSMenuItem(title: "Quit Water Reminder", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quit)

        statusItem?.menu = menu
    }

    private func startMenuUpdateTimer() {
        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.refreshNextReminderLabel()
        }
        refreshNextReminderLabel()
    }

    private func refreshNextReminderLabel() {
        guard let date = scheduler?.nextReminderDate else { return }
        let remaining = max(0, date.timeIntervalSinceNow)
        let mins = Int(remaining / 60)
        let secs = Int(remaining) % 60
        let label = mins > 0
            ? "Next drop in \(mins)m \(secs)s"
            : "Next drop in \(secs)s"
        nextReminderMenuItem?.title = label
    }

    @objc private func showNow() {
        showWaterReminder()
        scheduler?.reset()
    }

    @objc private func snooze5() {
        scheduler?.snooze(minutes: 5)
        refreshNextReminderLabel()
    }

    @objc private func setInterval(_ sender: NSMenuItem) {
        let mins = sender.tag
        currentIntervalMinutes = mins
        scheduler?.setInterval(minutes: mins)
        for item in intervalMenuItems {
            item.state = (item.tag == mins) ? .on : .off
        }
        refreshNextReminderLabel()
    }

    func showWaterReminder() {
        overlayController = OverlayWindowController()
        overlayController?.snoozeCallback = { [weak self] in
            self?.scheduler?.snooze(minutes: 5)
            self?.refreshNextReminderLabel()
        }
        overlayController?.showOverlay()
    }
}
