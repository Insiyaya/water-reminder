import SpriteKit

// Handles the glass drop, shatter, and shard physics.
extension WaterAnimationScene {

    func dropGlass() {
        let glass = buildGlass()
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
                guard let self, let glass else { return }
                self.shatter(glass, at: CGPoint(x: self.size.width / 2, y: landY))
            }
        ]))
    }

    // MARK: - Glass construction

    private func buildGlass() -> SKNode {
        let node = SKNode()
        node.addChild(glassBody())
        node.addChild(waterFill())
        node.addChild(shineStripe())
        node.addChild(bottomRim())
        return node
    }

    private func glassBody() -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to:    CGPoint(x: -30,  y:  80))
        path.addLine(to: CGPoint(x: -35,  y: -62))
        path.addLine(to: CGPoint(x:  35,  y: -62))
        path.addLine(to: CGPoint(x:  30,  y:  80))
        path.closeSubpath()

        let shape = SKShapeNode(path: path)
        shape.fillColor   = NSColor(red: 0.70, green: 0.88, blue: 1.00, alpha: 0.28)
        shape.strokeColor = NSColor(red: 0.85, green: 0.96, blue: 1.00, alpha: 0.90)
        shape.lineWidth   = 2.5
        return shape
    }

    private func waterFill() -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to:    CGPoint(x: -27,  y:  18))
        path.addLine(to: CGPoint(x: -33,  y: -60))
        path.addLine(to: CGPoint(x:  33,  y: -60))
        path.addLine(to: CGPoint(x:  27,  y:  18))
        path.closeSubpath()

        let shape = SKShapeNode(path: path)
        shape.fillColor   = NSColor(red: 0.20, green: 0.60, blue: 1.00, alpha: 0.78)
        shape.strokeColor = .clear
        return shape
    }

    private func shineStripe() -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to:    CGPoint(x: -14,  y:  70))
        path.addLine(to: CGPoint(x: -20,  y: -45))

        let shape = SKShapeNode(path: path)
        shape.strokeColor = NSColor(white: 1.0, alpha: 0.55)
        shape.lineWidth   = 5
        shape.lineCap     = .round
        return shape
    }

    private func bottomRim() -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to:    CGPoint(x: -35, y: -62))
        path.addLine(to: CGPoint(x:  35, y: -62))

        let shape = SKShapeNode(path: path)
        shape.strokeColor = NSColor(red: 0.85, green: 0.96, blue: 1.00, alpha: 0.90)
        shape.lineWidth   = 3
        return shape
    }

    // MARK: - Shatter sequence

    private func shatter(_ glass: SKNode, at position: CGPoint) {
        glass.removeFromParent()
        spawnImpactFlash(at: position)

        for i in 0..<10 {
            let angle = CGFloat(i) * (.pi * 2.0 / 10.0) + CGFloat.random(in: -0.25...0.25)
            spawnShard(from: position, angle: angle)
        }

        spawnWaterBurst(at: position)

        for i in 0..<5 {
            run(.sequence([
                .wait(forDuration: Double(i) * 0.11),
                .run { [weak self] in self?.spawnRipple(at: position) }
            ]))
        }

        run(.sequence([
            .wait(forDuration: 0.55),
            .run { [weak self] in self?.showReminderUI() }
        ]))
    }

    private func spawnImpactFlash(at position: CGPoint) {
        let flash = SKSpriteNode(
            color: NSColor(red: 0.55, green: 0.85, blue: 1.00, alpha: 0.55),
            size: CGSize(width: 100, height: 100)
        )
        flash.position  = position
        flash.zPosition = 20
        addChild(flash)
        flash.run(.sequence([
            .group([.scale(to: 4.5, duration: 0.18), .fadeOut(withDuration: 0.18)]),
            .removeFromParent()
        ]))
    }

    private func spawnShard(from origin: CGPoint, angle: CGFloat) {
        let a2 = angle + CGFloat.random(in: 0.35...1.1)
        let r1 = CGFloat.random(in: 14...38)
        let r2 = CGFloat.random(in: 14...38)

        let path = CGMutablePath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: cos(angle) * r1, y: sin(angle) * r1))
        path.addLine(to: CGPoint(x: cos(a2)    * r2, y: sin(a2)    * r2))
        path.closeSubpath()

        let shard = SKShapeNode(path: path)
        shard.position    = origin
        shard.fillColor   = NSColor(red: 0.65, green: 0.88, blue: 1.00, alpha: 0.60)
        shard.strokeColor = NSColor(red: 0.88, green: 0.97, blue: 1.00, alpha: 0.80)
        shard.lineWidth   = 1.5
        shard.zPosition   = 16
        addChild(shard)

        let dist = CGFloat.random(in: 130...380)
        let drop = CGFloat.random(in: 80...250)
        let dest = CGPoint(
            x: origin.x + cos(angle) * dist,
            y: origin.y + sin(angle) * dist - drop
        )
        let dur = Double.random(in: 0.55...0.95)

        shard.run(.sequence([
            .group([
                .move(to: dest, duration: dur),
                .rotate(byAngle: CGFloat.random(in: -.pi * 3 ... .pi * 3), duration: dur),
                .sequence([
                    .wait(forDuration: dur * 0.3),
                    .fadeOut(withDuration: dur * 0.7)
                ])
            ]),
            .removeFromParent()
        ]))
    }
}
