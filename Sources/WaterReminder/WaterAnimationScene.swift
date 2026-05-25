import SpriteKit

// MARK: - Scene

class WaterAnimationScene: SKScene {
    var dismissCallback: (() -> Void)?
    var snoozeCallback: (() -> Void)?

    private var waveNode1: SKShapeNode?
    private var waveNode2: SKShapeNode?
    private var wavePhase1: CGFloat = 0
    private var wavePhase2: CGFloat = .pi
    private var waveCurrentHeight: CGFloat = 0
    private var waveTargetHeight: CGFloat = 0
    private var lastTime: TimeInterval = 0
    private var isDismissing = false

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        setupBackground()
        setupWaves()
        startSequence()
    }

    // MARK: - Setup

    private func setupBackground() {
        let bg = SKSpriteNode(
            color: NSColor(red: 0.0, green: 0.04, blue: 0.14, alpha: 0.92),
            size: size
        )
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.zPosition = -10
        bg.alpha = 0
        addChild(bg)
        bg.run(.fadeIn(withDuration: 0.3))
    }

    private func setupWaves() {
        let w1 = SKShapeNode()
        w1.fillColor = NSColor(red: 0.08, green: 0.42, blue: 0.92, alpha: 0.70)
        w1.strokeColor = .clear
        w1.zPosition = 3
        addChild(w1)
        waveNode1 = w1

        let w2 = SKShapeNode()
        w2.fillColor = NSColor(red: 0.18, green: 0.58, blue: 1.00, alpha: 0.50)
        w2.strokeColor = .clear
        w2.zPosition = 4
        addChild(w2)
        waveNode2 = w2
    }

    // MARK: - Main sequence

    private func startSequence() {
        // 0.15s -glass drops
        run(.sequence([
            .wait(forDuration: 0.15),
            .run { [weak self] in self?.dropGlass() }
        ]))

        // 0.85s -wave begins rising after impact
        run(.sequence([
            .wait(forDuration: 0.85),
            .run { [weak self] in
                self?.waveTargetHeight = (self?.size.height ?? 300) * 0.20
            }
        ]))

        // 5.5s -auto dismiss
        run(.sequence([
            .wait(forDuration: 5.5),
            .run { [weak self] in self?.beginDismiss() }
        ]))
    }

    // MARK: - Glass

    private func dropGlass() {
        let glass = makeGlass()
        let landY = size.height * 0.56
        glass.position = CGPoint(x: size.width / 2, y: size.height + 140)
        glass.zPosition = 15
        addChild(glass)

        let fall = SKAction.move(to: CGPoint(x: size.width / 2, y: landY), duration: 0.52)
        fall.timingMode = .easeIn

        let wobble = SKAction.repeatForever(.sequence([
            .rotate(byAngle:  0.08, duration: 0.09),
            .rotate(byAngle: -0.16, duration: 0.09),
            .rotate(byAngle:  0.08, duration: 0.09)
        ]))

        glass.run(wobble)
        glass.run(.sequence([
            fall,
            .run { [weak self, weak glass] in
                glass?.removeAllActions()
                let pos = CGPoint(x: self!.size.width / 2, y: landY)
                self?.shatterGlass(glass!, at: pos)
            }
        ]))
    }

    private func makeGlass() -> SKNode {
        let container = SKNode()

        // Main body
        let bodyPath = CGMutablePath()
        bodyPath.move(to:    CGPoint(x: -30,  y:  80))
        bodyPath.addLine(to: CGPoint(x: -35,  y: -62))
        bodyPath.addLine(to: CGPoint(x:  35,  y: -62))
        bodyPath.addLine(to: CGPoint(x:  30,  y:  80))
        bodyPath.closeSubpath()

        let body = SKShapeNode(path: bodyPath)
        body.fillColor   = NSColor(red: 0.70, green: 0.88, blue: 1.00, alpha: 0.28)
        body.strokeColor = NSColor(red: 0.85, green: 0.96, blue: 1.00, alpha: 0.90)
        body.lineWidth   = 2.5
        container.addChild(body)

        // Water fill
        let waterPath = CGMutablePath()
        waterPath.move(to:    CGPoint(x: -27,  y:  18))
        waterPath.addLine(to: CGPoint(x: -33,  y: -60))
        waterPath.addLine(to: CGPoint(x:  33,  y: -60))
        waterPath.addLine(to: CGPoint(x:  27,  y:  18))
        waterPath.closeSubpath()

        let waterFill = SKShapeNode(path: waterPath)
        waterFill.fillColor   = NSColor(red: 0.20, green: 0.60, blue: 1.00, alpha: 0.78)
        waterFill.strokeColor = .clear
        container.addChild(waterFill)

        // Highlight stripe
        let shinePath = CGMutablePath()
        shinePath.move(to:    CGPoint(x: -14,  y:  70))
        shinePath.addLine(to: CGPoint(x: -20,  y: -45))

        let shine = SKShapeNode(path: shinePath)
        shine.strokeColor = NSColor(white: 1.0, alpha: 0.55)
        shine.lineWidth = 5
        shine.lineCap = .round
        container.addChild(shine)

        // Bottom rim
        let rimPath = CGMutablePath()
        rimPath.move(to:    CGPoint(x: -35, y: -62))
        rimPath.addLine(to: CGPoint(x:  35, y: -62))
        let rim = SKShapeNode(path: rimPath)
        rim.strokeColor = NSColor(red: 0.85, green: 0.96, blue: 1.00, alpha: 0.90)
        rim.lineWidth = 3
        container.addChild(rim)

        return container
    }

    // MARK: - Shatter

    private func shatterGlass(_ glass: SKNode, at position: CGPoint) {
        glass.removeFromParent()

        // Impact flash
        let flash = SKSpriteNode(
            color: NSColor(red: 0.55, green: 0.85, blue: 1.00, alpha: 0.55),
            size: CGSize(width: 100, height: 100)
        )
        flash.position = position
        flash.zPosition = 20
        addChild(flash)
        flash.run(.sequence([
            .group([.scale(to: 4.5, duration: 0.18), .fadeOut(withDuration: 0.18)]),
            .removeFromParent()
        ]))

        // Glass shards
        for i in 0..<10 {
            let baseAngle = CGFloat(i) * (.pi * 2.0 / 10.0) + CGFloat.random(in: -0.25...0.25)
            spawnShard(from: position, angle: baseAngle)
        }

        // Water burst particles
        spawnWaterBurst(at: position)

        // Expanding ripple rings
        for i in 0..<5 {
            run(.sequence([
                .wait(forDuration: Double(i) * 0.11),
                .run { [weak self] in self?.spawnRipple(at: position) }
            ]))
        }

        // Reminder text
        run(.sequence([
            .wait(forDuration: 0.55),
            .run { [weak self] in self?.showReminderText() }
        ]))
    }

    private func spawnShard(from origin: CGPoint, angle: CGFloat) {
        let a1 = angle
        let a2 = angle + CGFloat.random(in: 0.35...1.1)
        let r1 = CGFloat.random(in: 14...38)
        let r2 = CGFloat.random(in: 14...38)

        let path = CGMutablePath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: cos(a1) * r1, y: sin(a1) * r1))
        path.addLine(to: CGPoint(x: cos(a2) * r2, y: sin(a2) * r2))
        path.closeSubpath()

        let shard = SKShapeNode(path: path)
        shard.position = origin
        shard.fillColor   = NSColor(red: 0.65, green: 0.88, blue: 1.00, alpha: 0.60)
        shard.strokeColor = NSColor(red: 0.88, green: 0.97, blue: 1.00, alpha: 0.80)
        shard.lineWidth = 1.5
        shard.zPosition = 16
        addChild(shard)

        let dist = CGFloat.random(in: 130...380)
        let drop = CGFloat.random(in: 80...250)
        let dest = CGPoint(
            x: origin.x + cos(angle) * dist,
            y: origin.y + sin(angle) * dist - drop
        )
        let rot   = CGFloat.random(in: -.pi * 3 ... .pi * 3)
        let dur   = Double.random(in: 0.55...0.95)

        shard.run(.sequence([
            .group([
                .move(to: dest, duration: dur),
                .rotate(byAngle: rot, duration: dur),
                .sequence([
                    .wait(forDuration: dur * 0.3),
                    .fadeOut(withDuration: dur * 0.7)
                ])
            ]),
            .removeFromParent()
        ]))
    }

    // MARK: - Water particles

    private func spawnWaterBurst(at position: CGPoint) {
        let emitter = SKEmitterNode()
        emitter.particleTexture      = dropTexture()
        emitter.particleBirthRate    = 420
        emitter.numParticlesToEmit   = 220
        emitter.particleLifetime     = 2.4
        emitter.particleLifetimeRange = 1.0

        emitter.emissionAngle        = .pi / 2          // bias upward
        emitter.emissionAngleRange   = .pi * 1.9        // nearly all directions
        emitter.particleSpeed        = 380
        emitter.particleSpeedRange   = 230

        emitter.xAcceleration        = 0
        emitter.yAcceleration        = -620             // gravity

        emitter.particleAlpha        = 0.90
        emitter.particleAlphaRange   = 0.10
        emitter.particleAlphaSpeed   = -0.32

        emitter.particleScale        = 0.28
        emitter.particleScaleRange   = 0.18
        emitter.particleScaleSpeed   = -0.04

        emitter.particleColor        = NSColor(red: 0.28, green: 0.68, blue: 1.00, alpha: 1.0)
        emitter.particleColorBlendFactor = 1.0

        emitter.position  = position
        emitter.zPosition = 17
        addChild(emitter)

        emitter.run(.sequence([
            .wait(forDuration: 0.18),
            .run { emitter.particleBirthRate = 0 },
            .wait(forDuration: 3.5),
            .removeFromParent()
        ]))
    }

    private func dropTexture() -> SKTexture {
        let size = CGSize(width: 22, height: 22)
        let image = NSImage(size: size, flipped: false) { rect in
            // Drop base
            NSColor(red: 0.35, green: 0.72, blue: 1.00, alpha: 1.0).setFill()
            NSBezierPath(ovalIn: rect.insetBy(dx: 2, dy: 2)).fill()
            // Highlight
            NSColor(white: 1.0, alpha: 0.55).setFill()
            NSBezierPath(ovalIn: NSRect(x: 5, y: 11, width: 7, height: 7)).fill()
            return true
        }
        return SKTexture(image: image)
    }

    // MARK: - Ripples

    private func spawnRipple(at position: CGPoint) {
        let ripple = SKShapeNode(circleOfRadius: 6)
        ripple.position   = position
        ripple.strokeColor = NSColor(red: 0.40, green: 0.78, blue: 1.00, alpha: 0.75)
        ripple.fillColor   = .clear
        ripple.lineWidth   = 3.0
        ripple.zPosition   = 14
        addChild(ripple)

        let maxScale = CGFloat.random(in: 22...42)
        ripple.run(.sequence([
            .group([
                .scale(to: maxScale, duration: 1.4),
                .fadeOut(withDuration: 1.4)
            ]),
            .removeFromParent()
        ]))
    }

    // MARK: - UI Text

    private func showReminderText() {
        let cx = size.width / 2
        let cy = size.height * 0.40

        // Big drop icon (SF Symbol)
        let dropIcon = symbolSprite(
            name: "drop.fill",
            pointSize: 110,
            tint: NSColor(red: 0.35, green: 0.80, blue: 1.00, alpha: 1.0)
        )
        dropIcon.position  = CGPoint(x: cx, y: cy + 130)
        dropIcon.zPosition = 25
        dropIcon.alpha     = 0
        dropIcon.setScale(0.3)
        addChild(dropIcon)
        dropIcon.run(.sequence([
            .group([
                .fadeIn(withDuration: 0.15),
                .scale(to: 1.12, duration: 0.20)
            ]),
            .scale(to: 1.0, duration: 0.10)
        ]))
        dropIcon.run(.repeatForever(.sequence([
            .moveBy(x: 0, y: 12, duration: 1.1),
            .moveBy(x: 0, y: -12, duration: 1.1)
        ])))

        // Headline
        let headline = makeLabel("Stay Hydrated!", font: "Helvetica-Bold", size: 72, color: .white)
        headline.position = CGPoint(x: cx, y: cy + 30)
        headline.zPosition = 25
        addChild(headline)
        headline.run(.sequence([.wait(forDuration: 0.10), .fadeIn(withDuration: 0.30)]))

        // Science fact
        let fact = makeLabel(
            "Science says: drink 200 ml every 25 min for peak focus & energy",
            font: "Helvetica",
            size: 22,
            color: NSColor(red: 0.55, green: 0.85, blue: 1.00, alpha: 0.90)
        )
        fact.position = CGPoint(x: cx, y: cy - 20)
        fact.zPosition = 25
        addChild(fact)
        fact.run(.sequence([.wait(forDuration: 0.22), .fadeIn(withDuration: 0.30)]))

        // Snooze button
        let snoozeBtn = makeButton(text: "Snooze 5 min", name: "snoozeBtn", iconSymbol: "clock.arrow.circlepath")
        snoozeBtn.position = CGPoint(x: cx - 140, y: cy - 80)
        snoozeBtn.zPosition = 25
        addChild(snoozeBtn)
        snoozeBtn.run(.sequence([.wait(forDuration: 0.35), .fadeIn(withDuration: 0.25)]))

        // Dismiss button
        let dismissBtn = makeButton(text: "Done - I drank!", name: "dismissBtn", iconSymbol: "checkmark.circle.fill", primary: true)
        dismissBtn.position = CGPoint(x: cx + 140, y: cy - 80)
        dismissBtn.zPosition = 25
        addChild(dismissBtn)
        dismissBtn.run(.sequence([.wait(forDuration: 0.35), .fadeIn(withDuration: 0.25)]))

        // Hint
        let hint = makeLabel(
            "Click anywhere to dismiss",
            font: "Helvetica",
            size: 15,
            color: NSColor(white: 1.0, alpha: 0.35)
        )
        hint.position = CGPoint(x: cx, y: cy - 135)
        hint.zPosition = 25
        addChild(hint)
        hint.run(.sequence([.wait(forDuration: 0.50), .fadeIn(withDuration: 0.30)]))
    }

    private func makeLabel(_ text: String, font: String, size: CGFloat, color: NSColor) -> SKLabelNode {
        let label = SKLabelNode()
        label.text      = text
        label.fontName  = font
        label.fontSize  = size
        label.fontColor = color
        label.alpha     = 0
        label.horizontalAlignmentMode = .center
        return label
    }

    private func makeButton(text: String, name: String, iconSymbol: String? = nil, primary: Bool = false) -> SKNode {
        let container = SKNode()
        container.name  = name
        container.alpha = 0

        let bg = SKShapeNode(rectOf: CGSize(width: 230, height: 50), cornerRadius: 25)
        bg.name        = name
        bg.fillColor   = primary
            ? NSColor(red: 0.18, green: 0.58, blue: 1.00, alpha: 0.90)
            : NSColor(white: 1.0, alpha: 0.14)
        bg.strokeColor = primary
            ? NSColor(red: 0.40, green: 0.78, blue: 1.00, alpha: 0.80)
            : NSColor(white: 1.0, alpha: 0.30)
        bg.lineWidth   = 1.5
        container.addChild(bg)

        let labelOffsetX: CGFloat = iconSymbol != nil ? 14 : 0

        let label = SKLabelNode()
        label.name      = name
        label.text      = text
        label.fontName  = "Helvetica"
        label.fontSize  = 17
        label.fontColor = .white
        label.verticalAlignmentMode   = .center
        label.horizontalAlignmentMode = .center
        label.position  = CGPoint(x: labelOffsetX, y: 0)
        container.addChild(label)

        if let sym = iconSymbol {
            let icon = symbolSprite(name: sym, pointSize: 17, tint: .white)
            icon.name     = name
            icon.position = CGPoint(x: labelOffsetX - label.frame.width / 2 - icon.size.width / 2 - 6, y: 0)
            container.addChild(icon)
        }

        return container
    }

    private func symbolSprite(name: String, pointSize: CGFloat, tint: NSColor) -> SKSpriteNode {
        let sizeCfg  = NSImage.SymbolConfiguration(pointSize: pointSize, weight: .medium)
        let colorCfg = NSImage.SymbolConfiguration(paletteColors: [tint])
        let combined = sizeCfg.applying(colorCfg)
        guard let image = NSImage(systemSymbolName: name, accessibilityDescription: nil)?
            .withSymbolConfiguration(combined) else {
            return SKSpriteNode()
        }
        return SKSpriteNode(texture: SKTexture(image: image), size: image.size)
    }

    // MARK: - Wave update loop

    override func update(_ currentTime: TimeInterval) {
        if lastTime == 0 { lastTime = currentTime }
        let dt = currentTime - lastTime
        lastTime = currentTime

        wavePhase1 += CGFloat(dt) * 1.8
        wavePhase2 += CGFloat(dt) * 2.5

        if waveCurrentHeight < waveTargetHeight {
            waveCurrentHeight = min(
                waveCurrentHeight + CGFloat(dt) * 65,
                waveTargetHeight
            )
        }

        waveNode1?.path = wavePath(phase: wavePhase1, amplitude: 20, baseH: waveCurrentHeight)
        waveNode2?.path = wavePath(phase: wavePhase2, amplitude: 13, baseH: waveCurrentHeight * 0.82)
    }

    private func wavePath(phase: CGFloat, amplitude: CGFloat, baseH: CGFloat) -> CGPath {
        guard baseH > 0 else { return CGPath(rect: .zero, transform: nil) }
        let path  = CGMutablePath()
        let w     = size.width
        let step  : CGFloat = 4

        // bottom-left → wave top edge → bottom-right → close
        path.move(to: CGPoint(x: 0, y: 0))

        var x: CGFloat = 0
        while x <= w + step {
            let y = baseH + sin(x / 75.0 + phase) * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
            x += step
        }

        path.addLine(to: CGPoint(x: w, y: 0))
        path.closeSubpath()
        return path
    }

    // MARK: - Input / dismiss

    override func mouseDown(with event: NSEvent) {
        guard let sceneView = view else { return }
        let viewPt  = event.locationInWindow
        let scenePt = sceneView.convert(viewPt, to: self)

        // Check buttons first
        for node in nodes(at: scenePt) {
            if node.name == "snoozeBtn" { snoozeCallback?(); return }
            if node.name == "dismissBtn" { beginDismiss(); return }
        }
        beginDismiss()
    }

    override func keyDown(with event: NSEvent) {
        beginDismiss()
    }

    private func beginDismiss() {
        guard !isDismissing else { return }
        isDismissing = true
        run(.sequence([
            .fadeOut(withDuration: 0.35),
            .run { [weak self] in self?.dismissCallback?() }
        ]))
    }
}
