import SpriteKit

// Core scene: owns all state, handles lifecycle/input/dismiss.
// Animation logic lives in focused extensions (+Glass, +Particles, +Wave, +Ripple, +UI).
class WaterAnimationScene: SKScene {

    // MARK: - Callbacks
    var dismissCallback: (() -> Void)?
    var snoozeCallback:  (() -> Void)?

    // MARK: - Wave state (mutated by +Wave extension)
    var waveNode1:         SKShapeNode?
    var waveNode2:         SKShapeNode?
    var wavePhase1:        CGFloat     = 0
    var wavePhase2:        CGFloat     = .pi
    var waveCurrentHeight: CGFloat     = 0
    var waveTargetHeight:  CGFloat     = 0
    var lastFrameTime:     TimeInterval = 0

    // MARK: - Private
    private var isDismissing = false

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        setupBackground()
        setupWaves()
        startSequence()
    }

    override func update(_ currentTime: TimeInterval) {
        updateWaves(currentTime: currentTime)
    }

    // MARK: - Background

    private func setupBackground() {
        let bg = SKSpriteNode(
            color: NSColor(red: 0.0, green: 0.04, blue: 0.14, alpha: 0.92),
            size: size
        )
        bg.position  = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.zPosition = -10
        bg.alpha     = 0
        addChild(bg)
        bg.run(.fadeIn(withDuration: 0.3))
    }

    // MARK: - Sequence

    private func startSequence() {
        run(.sequence([
            .wait(forDuration: 0.15),
            .run { [weak self] in self?.dropGlass() }
        ]))
        run(.sequence([
            .wait(forDuration: 0.85),
            .run { [weak self] in
                self?.waveTargetHeight = (self?.size.height ?? 300) * 0.20
            }
        ]))
        // No auto-dismiss: overlay stays until the user clicks or presses a key.
    }

    // MARK: - Input

    override func mouseDown(with event: NSEvent) {
        guard let sceneView = view else { return }
        let pt = sceneView.convert(event.locationInWindow, to: self)
        for node in nodes(at: pt) {
            if node.name == "snoozeBtn"  { snoozeCallback?(); return }
            if node.name == "dismissBtn" { beginDismiss(); return }
        }
        beginDismiss()
    }

    override func keyDown(with event: NSEvent) {
        beginDismiss()
    }

    // MARK: - Dismiss

    func beginDismiss() {
        guard !isDismissing else { return }
        isDismissing = true
        run(.sequence([
            .fadeOut(withDuration: 0.35),
            .run { [weak self] in self?.dismissCallback?() }
        ]))
    }
}
