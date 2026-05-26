import SpriteKit

// Spawns expanding ring ripples at the glass impact point.
extension WaterAnimationScene {

    func spawnRipple(at position: CGPoint) {
        let ring = SKShapeNode(circleOfRadius: 6)
        ring.position    = position
        ring.strokeColor = NSColor(red: 0.40, green: 0.78, blue: 1.00, alpha: 0.75)
        ring.fillColor   = .clear
        ring.lineWidth   = 3.0
        ring.zPosition   = 14
        addChild(ring)

        let maxScale = CGFloat.random(in: 22...42)
        ring.run(.sequence([
            .group([
                .scale(to: maxScale, duration: 1.4),
                .fadeOut(withDuration: 1.4)
            ]),
            .removeFromParent()
        ]))
    }
}
