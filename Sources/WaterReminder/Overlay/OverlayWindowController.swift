import AppKit
import SpriteKit

final class OverlayWindowController: NSObject {
    var snoozeCallback: (() -> Void)?

    private var windows: [NSWindow] = []

    // MARK: - Public API

    func showOverlay() {
        for screen in NSScreen.screens {
            let window = makeWindow(for: screen)
            let scene  = makeScene(size: screen.frame.size)
            let view   = makeSKView(size: screen.frame.size, scene: scene)

            window.contentView = view
            window.makeKeyAndOrderFront(nil)
            windows.append(window)
        }
        NSApp.activate(ignoringOtherApps: true)
    }

    func dismissAll() {
        windows.forEach { $0.close() }
        windows.removeAll()
    }

    // MARK: - Factories

    private func makeWindow(for screen: NSScreen) -> NSWindow {
        let win = NSWindow(
            contentRect: screen.frame,
            styleMask:   .borderless,
            backing:     .buffered,
            defer:       false,
            screen:      screen
        )
        win.level                = .screenSaver   // above all apps: Slack, Chrome, etc.
        win.isOpaque             = false
        win.backgroundColor      = .clear
        win.hasShadow            = false
        win.isReleasedWhenClosed = false
        win.collectionBehavior   = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        return win
    }

    private func makeScene(size: CGSize) -> WaterAnimationScene {
        let scene = WaterAnimationScene(size: size)
        scene.scaleMode       = .resizeFill
        scene.backgroundColor = .clear
        scene.dismissCallback = { [weak self] in self?.dismissAll() }
        scene.snoozeCallback  = { [weak self] in
            self?.snoozeCallback?()
            self?.dismissAll()
        }
        return scene
    }

    private func makeSKView(size: CGSize, scene: WaterAnimationScene) -> SKView {
        let view = SKView(frame: NSRect(origin: .zero, size: size))
        view.allowsTransparency = true
        view.ignoresSiblingOrder = true
        view.presentScene(scene)
        return view
    }
}
