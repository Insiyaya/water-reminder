import SpriteKit

// Manages the water particle burst emitted on glass impact.
extension WaterAnimationScene {

    func spawnWaterBurst(at position: CGPoint) {
        let emitter = configuredEmitter()
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

    // MARK: - Private

    private func configuredEmitter() -> SKEmitterNode {
        let e = SKEmitterNode()
        e.particleTexture       = waterDropTexture()
        e.particleBirthRate     = 420
        e.numParticlesToEmit    = 220
        e.particleLifetime      = 2.4
        e.particleLifetimeRange = 1.0

        e.emissionAngle      = .pi / 2    // bias upward
        e.emissionAngleRange = .pi * 1.9  // nearly all directions
        e.particleSpeed      = 380
        e.particleSpeedRange = 230

        e.xAcceleration = 0
        e.yAcceleration = -620            // gravity

        e.particleAlpha        = 0.90
        e.particleAlphaRange   = 0.10
        e.particleAlphaSpeed   = -0.32
        e.particleScale        = 0.28
        e.particleScaleRange   = 0.18
        e.particleScaleSpeed   = -0.04

        e.particleColor            = NSColor(red: 0.28, green: 0.68, blue: 1.00, alpha: 1.0)
        e.particleColorBlendFactor = 1.0
        return e
    }

    private func waterDropTexture() -> SKTexture {
        let sz = CGSize(width: 22, height: 22)
        let image = NSImage(size: sz, flipped: false) { rect in
            NSColor(red: 0.35, green: 0.72, blue: 1.00, alpha: 1.0).setFill()
            NSBezierPath(ovalIn: rect.insetBy(dx: 2, dy: 2)).fill()
            NSColor(white: 1.0, alpha: 0.55).setFill()
            NSBezierPath(ovalIn: NSRect(x: 5, y: 11, width: 7, height: 7)).fill()
            return true
        }
        return SKTexture(image: image)
    }
}
