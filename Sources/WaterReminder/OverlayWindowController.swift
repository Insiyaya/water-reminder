import AppKit
import SpriteKit

class OverlayWindowController: NSObject {
    private var windows: [NSWindow] = []
    var snoozeCallback: (() -> Void)?

    func showOverlay() {
        for screen in NSScreen.screens {
            let window = makeOverlayWindow(for: screen)
            let scene = WaterAnimationScene(size: screen.frame.size)
            scene.scaleMode = .resizeFill
            scene.backgroundColor = .clear
            scene.dismissCallback = { [weak self] in self?.dismissAll() }
            scene.snoozeCallback = { [weak self] in
                self?.snoozeCallback?()
                self?.dismissAll()
            }

            let skView = SKView(frame: NSRect(origin: .zero, size: screen.frame.size))
            skView.allowsTransparency = true
            skView.ignoresSiblingOrder = true
            skView.presentScene(scene)

            window.contentView = skView
            window.makeKeyAndOrderFront(nil)
            windows.append(window)
        }
        NSApp.activate(ignoringOtherApps: true)
    }

    private func makeOverlayWindow(for screen: NSScreen) -> NSWindow {
        let win = NSWindow(
            contentRect: screen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false,
            screen: screen
        )
        win.level = .screenSaver          // above everything — Slack, Chrome, etc.
        win.isOpaque = false
        win.backgroundColor = .clear
        win.hasShadow = false
        win.isReleasedWhenClosed = false
        win.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        win.acceptsMouseMovedEvents = true
        return win
    }

    func dismissAll() {
        for win in windows { win.close() }
        windows.removeAll()
    }
}
