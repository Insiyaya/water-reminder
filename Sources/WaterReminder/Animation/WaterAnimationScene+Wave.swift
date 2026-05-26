import SpriteKit

// Creates and animates the rising water-wave layer at the bottom of the overlay.
extension WaterAnimationScene {

    func setupWaves() {
        waveNode1 = addWaveLayer(
            fill: NSColor(red: 0.08, green: 0.42, blue: 0.92, alpha: 0.70),
            zPos: 3
        )
        waveNode2 = addWaveLayer(
            fill: NSColor(red: 0.18, green: 0.58, blue: 1.00, alpha: 0.50),
            zPos: 4
        )
    }

    func updateWaves(currentTime: TimeInterval) {
        if lastFrameTime == 0 { lastFrameTime = currentTime }
        let dt = currentTime - lastFrameTime
        lastFrameTime = currentTime

        wavePhase1 += CGFloat(dt) * 1.8
        wavePhase2 += CGFloat(dt) * 2.5

        if waveCurrentHeight < waveTargetHeight {
            waveCurrentHeight = min(waveCurrentHeight + CGFloat(dt) * 65, waveTargetHeight)
        }

        waveNode1?.path = wavePath(phase: wavePhase1, amplitude: 20,   baseH: waveCurrentHeight)
        waveNode2?.path = wavePath(phase: wavePhase2, amplitude: 13, baseH: waveCurrentHeight * 0.82)
    }

    // MARK: - Private

    private func addWaveLayer(fill: NSColor, zPos: CGFloat) -> SKShapeNode {
        let node = SKShapeNode()
        node.fillColor  = fill
        node.strokeColor = .clear
        node.zPosition  = zPos
        addChild(node)
        return node
    }

    private func wavePath(phase: CGFloat, amplitude: CGFloat, baseH: CGFloat) -> CGPath {
        guard baseH > 0 else { return CGPath(rect: .zero, transform: nil) }
        let path  = CGMutablePath()
        let width = size.width
        let step: CGFloat = 4

        path.move(to: CGPoint(x: 0, y: 0))
        var x: CGFloat = 0
        while x <= width + step {
            path.addLine(to: CGPoint(x: x, y: baseH + sin(x / 75.0 + phase) * amplitude))
            x += step
        }
        path.addLine(to: CGPoint(x: width, y: 0))
        path.closeSubpath()
        return path
    }
}
