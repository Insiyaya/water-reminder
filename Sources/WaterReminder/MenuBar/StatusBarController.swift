import AppKit

final class StatusBarController: NSObject {
    // MARK: - Callbacks (set by AppDelegate)
    var onShowNow:        (() -> Void)?
    var onSnooze:         (() -> Void)?
    var onIntervalChanged: ((Int) -> Void)?

    // MARK: - State
    private(set) var intervalMinutes: Int = 25

    private var statusItem:       NSStatusItem?
    private var countdownItem:    NSMenuItem?
    private var intervalItems:    [NSMenuItem] = []

    // MARK: - Public API

    func setup() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        configureButton()
        buildMenu()
    }

    func updateCountdown(secondsRemaining: TimeInterval) {
        let mins = Int(secondsRemaining / 60)
        let secs = Int(secondsRemaining) % 60
        countdownItem?.title = mins > 0
            ? "Next drop in \(mins)m \(secs)s"
            : "Next drop in \(secs)s"
    }

    // MARK: - Button

    private func configureButton() {
        guard let button = statusItem?.button else { return }
        let cfg = NSImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        if let img = NSImage(systemSymbolName: "drop.fill", accessibilityDescription: "Water Reminder")?
            .withSymbolConfiguration(cfg) {
            img.isTemplate = true
            button.image = img
            button.imageScaling = .scaleProportionallyDown
        }
    }

    // MARK: - Menu construction

    private func buildMenu() {
        let menu = NSMenu()

        menu.addItem(sectionHeader("Water Reminder", icon: "drop.fill"))
        menu.addItem(.separator())

        let countdown = makeItem(title: "Next reminder: calculating...", icon: "clock")
        countdown.isEnabled = false
        countdownItem = countdown
        menu.addItem(countdown)
        menu.addItem(.separator())

        menu.addItem(makeItem(title: "Hydrate Now!", icon: "drop.fill",
                              action: #selector(didTapShowNow), key: "d"))
        menu.addItem(makeItem(title: "Snooze 5 minutes", icon: "clock.arrow.circlepath",
                              action: #selector(didTapSnooze)))
        menu.addItem(.separator())
        menu.addItem(intervalSubmenu())
        menu.addItem(.separator())
        menu.addItem(makeItem(title: "Quit Water Reminder", icon: "xmark.circle",
                              action: #selector(NSApplication.terminate(_:)), key: "q"))

        statusItem?.menu = menu
    }

    private func intervalSubmenu() -> NSMenuItem {
        let sub = NSMenu()
        intervalItems.removeAll()
        for mins in [15, 20, 25, 30, 45, 60] {
            let item = makeItem(title: "\(mins) minutes", action: #selector(didTapInterval(_:)))
            item.tag   = mins
            item.state = (mins == intervalMinutes) ? .on : .off
            sub.addItem(item)
            intervalItems.append(item)
        }
        let parent = makeItem(title: "Reminder Interval", icon: "timer")
        parent.submenu = sub
        return parent
    }

    // MARK: - Item factory

    private func sectionHeader(_ title: String, icon: String) -> NSMenuItem {
        let item = makeItem(title: title, icon: icon)
        item.isEnabled = false
        return item
    }

    private func makeItem(title: String, icon: String? = nil,
                          action: Selector? = nil, key: String = "") -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: key)
        item.target = self
        if let sym = icon {
            let cfg = NSImage.SymbolConfiguration(pointSize: 13, weight: .regular)
            if let img = NSImage(systemSymbolName: sym, accessibilityDescription: nil)?
                .withSymbolConfiguration(cfg) {
                img.isTemplate = true
                item.image = img
            }
        }
        return item
    }

    // MARK: - Actions

    @objc private func didTapShowNow()              { onShowNow?() }
    @objc private func didTapSnooze()               { onSnooze?() }

    @objc private func didTapInterval(_ sender: NSMenuItem) {
        intervalMinutes = sender.tag
        intervalItems.forEach { $0.state = ($0.tag == intervalMinutes) ? .on : .off }
        onIntervalChanged?(intervalMinutes)
    }
}
