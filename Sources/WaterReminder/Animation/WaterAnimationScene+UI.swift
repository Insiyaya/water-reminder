import SpriteKit

// Builds the reminder UI: drop icon, headline, science fact, action buttons, hint.
extension WaterAnimationScene {

    func showReminderUI() {
        let cx = size.width  / 2
        let cy = size.height * 0.40

        addDropIcon(cx: cx, cy: cy)
        addHeadline(cx: cx, cy: cy)
        addScienceFact(cx: cx, cy: cy)
        addActionButtons(cx: cx, cy: cy)
        addDismissHint(cx: cx, cy: cy)
    }

    // MARK: - UI components

    private func addDropIcon(cx: CGFloat, cy: CGFloat) {
        let icon = symbolSprite(
            name: "drop.fill",
            pointSize: 110,
            tint: NSColor(red: 0.35, green: 0.80, blue: 1.00, alpha: 1.0)
        )
        icon.position  = CGPoint(x: cx, y: cy + 130)
        icon.zPosition = 25
        icon.alpha     = 0
        icon.setScale(0.3)
        addChild(icon)

        icon.run(.sequence([
            .group([.fadeIn(withDuration: 0.15), .scale(to: 1.12, duration: 0.20)]),
            .scale(to: 1.0, duration: 0.10)
        ]))
        icon.run(.repeatForever(.sequence([
            .moveBy(x: 0, y: 12, duration: 1.1),
            .moveBy(x: 0, y: -12, duration: 1.1)
        ])))
    }

    private func addHeadline(cx: CGFloat, cy: CGFloat) {
        let label = styledLabel("Stay Hydrated!", font: "Helvetica-Bold", size: 72, color: .white)
        label.position  = CGPoint(x: cx, y: cy + 30)
        label.zPosition = 25
        addChild(label)
        label.run(.sequence([.wait(forDuration: 0.10), .fadeIn(withDuration: 0.30)]))
    }

    private func addScienceFact(cx: CGFloat, cy: CGFloat) {
        let label = styledLabel(
            "Science says: drink 200 ml every 25 min for peak focus and energy",
            font: "Helvetica", size: 22,
            color: NSColor(red: 0.55, green: 0.85, blue: 1.00, alpha: 0.90)
        )
        label.position  = CGPoint(x: cx, y: cy - 20)
        label.zPosition = 25
        addChild(label)
        label.run(.sequence([.wait(forDuration: 0.22), .fadeIn(withDuration: 0.30)]))
    }

    private func addActionButtons(cx: CGFloat, cy: CGFloat) {
        let snooze = overlayButton(
            text: "Snooze 5 min", name: "snoozeBtn",
            icon: "clock.arrow.circlepath"
        )
        snooze.position  = CGPoint(x: cx - 140, y: cy - 80)
        snooze.zPosition = 25
        addChild(snooze)
        snooze.run(.sequence([.wait(forDuration: 0.35), .fadeIn(withDuration: 0.25)]))

        let done = overlayButton(
            text: "Done - I drank!", name: "dismissBtn",
            icon: "checkmark.circle.fill", primary: true
        )
        done.position  = CGPoint(x: cx + 140, y: cy - 80)
        done.zPosition = 25
        addChild(done)
        done.run(.sequence([.wait(forDuration: 0.35), .fadeIn(withDuration: 0.25)]))
    }

    private func addDismissHint(cx: CGFloat, cy: CGFloat) {
        let hint = styledLabel(
            "Click anywhere to dismiss",
            font: "Helvetica", size: 15,
            color: NSColor(white: 1.0, alpha: 0.35)
        )
        hint.position  = CGPoint(x: cx, y: cy - 135)
        hint.zPosition = 25
        addChild(hint)
        hint.run(.sequence([.wait(forDuration: 0.50), .fadeIn(withDuration: 0.30)]))
    }

    // MARK: - Node factories

    private func styledLabel(_ text: String, font: String, size: CGFloat, color: NSColor) -> SKLabelNode {
        let label = SKLabelNode()
        label.text      = text
        label.fontName  = font
        label.fontSize  = size
        label.fontColor = color
        label.alpha     = 0
        label.horizontalAlignmentMode = .center
        return label
    }

    private func overlayButton(text: String, name: String,
                                icon: String? = nil, primary: Bool = false) -> SKNode {
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

        let offsetX: CGFloat = icon != nil ? 14 : 0
        let label = SKLabelNode()
        label.name      = name
        label.text      = text
        label.fontName  = "Helvetica"
        label.fontSize  = 17
        label.fontColor = .white
        label.verticalAlignmentMode   = .center
        label.horizontalAlignmentMode = .center
        label.position  = CGPoint(x: offsetX, y: 0)
        container.addChild(label)

        if let sym = icon {
            let iconNode = symbolSprite(name: sym, pointSize: 17, tint: .white)
            iconNode.name     = name
            iconNode.position = CGPoint(
                x: offsetX - label.frame.width / 2 - iconNode.size.width / 2 - 6, y: 0
            )
            container.addChild(iconNode)
        }

        return container
    }

    private func symbolSprite(name: String, pointSize: CGFloat, tint: NSColor) -> SKSpriteNode {
        let sizeCfg  = NSImage.SymbolConfiguration(pointSize: pointSize, weight: .medium)
        let colorCfg = NSImage.SymbolConfiguration(paletteColors: [tint])
        guard let image = NSImage(systemSymbolName: name, accessibilityDescription: nil)?
            .withSymbolConfiguration(sizeCfg.applying(colorCfg)) else {
            return SKSpriteNode()
        }
        return SKSpriteNode(texture: SKTexture(image: image), size: image.size)
    }
}
