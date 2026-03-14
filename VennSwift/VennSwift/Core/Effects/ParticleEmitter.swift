import SwiftUI
import UIKit
import QuartzCore

// MARK: - PremiumParticleEmitter
// CAEmitterLayer-based particle system. CAEmitterLayer runs entirely on the
// render server — zero CPU involvement after the initial setup, same technology
// Apple uses for Messages screen effects.

struct PremiumParticleEmitter: UIViewRepresentable {

    // MARK: Preset

    enum Preset {
        case confetti
        case sparkles
        case ambientOrbs
        case custom(configure: (CAEmitterLayer, [CAEmitterCell]) -> Void)
    }

    // MARK: Configuration

    var preset: Preset
    var isEmitting: Bool = true
    /// Birth-rate multiplier applied on top of each preset's default birth rate.
    var birthRate: Float = 1.0

    // MARK: UIViewRepresentable

    func makeUIView(context: Context) -> UIView {
        let view = EmitterHostView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false

        let emitter = CAEmitterLayer()
        emitter.renderMode = .additive

        configureEmitter(emitter, in: view)

        view.layer.addSublayer(emitter)
        view.emitterLayer = emitter

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let view = uiView as? EmitterHostView,
              let emitter = view.emitterLayer else { return }

        // Toggling birthRate to zero is the correct way to pause emission —
        // setting isEnabled would destroy the existing live particles.
        let targetRate: Float = isEmitting ? birthRate : 0.0
        emitter.birthRate = targetRate

        // Reposition emitter origin when bounds change (rotation, split view)
        positionEmitter(emitter, in: uiView)
    }

    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        guard let view = uiView as? EmitterHostView else { return }
        view.emitterLayer?.removeFromSuperlayer()
        view.emitterLayer = nil
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    // MARK: Coordinator

    final class Coordinator {}

    // MARK: - Configuration

    private func configureEmitter(_ emitter: CAEmitterLayer, in view: UIView) {
        positionEmitter(emitter, in: view)

        switch preset {
        case .confetti:
            configureConfetti(emitter)
        case .sparkles:
            configureSparkles(emitter)
        case .ambientOrbs:
            configureAmbientOrbs(emitter)
        case .custom(let configure):
            let cell = CAEmitterCell()
            configure(emitter, [cell])
        }

        // Apply birth-rate multiplier after preset sets defaults
        emitter.birthRate = isEmitting ? birthRate : 0.0
    }

    private func positionEmitter(_ emitter: CAEmitterLayer, in view: UIView) {
        let bounds = view.bounds.isEmpty
            ? CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            : view.bounds

        switch preset {
        case .confetti:
            // Emit from a horizontal band across the top edge
            emitter.emitterPosition = CGPoint(x: bounds.midX, y: -20)
            emitter.emitterSize = CGSize(width: bounds.width * 1.2, height: 1)
            emitter.emitterShape = .line
        case .sparkles:
            // Emit from center, spreading in all directions
            emitter.emitterPosition = CGPoint(x: bounds.midX, y: bounds.midY)
            emitter.emitterSize = CGSize(width: bounds.width * 0.6, height: bounds.height * 0.6)
            emitter.emitterShape = .rectangle
        case .ambientOrbs:
            // Emit from center, slow drift fills the space
            emitter.emitterPosition = CGPoint(x: bounds.midX, y: bounds.midY)
            emitter.emitterSize = CGSize(width: bounds.width, height: bounds.height)
            emitter.emitterShape = .rectangle
        case .custom:
            emitter.emitterPosition = CGPoint(x: bounds.midX, y: bounds.midY)
            emitter.emitterSize = CGSize(width: bounds.width, height: bounds.height)
            emitter.emitterShape = .rectangle
        }
    }

    // MARK: - Confetti Preset

    private func configureConfetti(_ emitter: CAEmitterLayer) {
        // Venn palette + white and pink for variety
        let colors: [UIColor] = [
            UIColor(hex: "#FF6347"), // coral
            UIColor(hex: "#FFB347"), // gold
            UIColor(hex: "#818CF8"), // indigo
            UIColor.white,
            UIColor(hex: "#FF69B4"), // pink
            UIColor(hex: "#34D399"), // green accent for contrast
        ]

        var cells: [CAEmitterCell] = []

        // We create multiple cell variants — thin rectangles, squares, circles —
        // each with slightly different physics so the spread looks natural.
        let shapes: [(CGImage?, String)] = [
            (makeRectImage(width: 8, height: 4), "rect_wide"),
            (makeRectImage(width: 5, height: 5), "rect_square"),
            (makeCircleImage(diameter: 5), "circle"),
            (makeRectImage(width: 10, height: 3), "rect_thin"),
            (makeCircleImage(diameter: 3), "circle_small"),
            (makeRectImage(width: 6, height: 6), "rect_med"),
        ]

        for (index, (image, name)) in shapes.enumerated() {
            let colorIndex = index % colors.count
            let cell = CAEmitterCell()
            cell.name = name
            cell.contents = image

            // Physics — gravity, velocity, spread
            cell.birthRate = 40
            cell.lifetime = 4.0
            cell.lifetimeRange = 1.5
            cell.velocity = 220
            cell.velocityRange = 100
            cell.emissionLongitude = .pi / 2  // downward
            cell.emissionRange = .pi           // full horizontal spread
            cell.yAcceleration = 200           // gravity

            // Rotation — different spin rates per shape keeps it from looking uniform
            let spinVariants: [CGFloat] = [2.0, 3.5, 1.5, 4.0, 2.8, 1.2]
            cell.spin = spinVariants[index % spinVariants.count]
            cell.spinRange = 2.0

            // Scale
            cell.scale = 0.3
            cell.scaleRange = 0.2

            // Color and fade
            cell.color = colors[colorIndex].cgColor
            cell.alphaSpeed = -0.20  // fade over the last portion of lifetime
            cell.alphaRange = 0.3

            cells.append(cell)
        }

        emitter.emitterCells = cells
    }

    // MARK: - Sparkles Preset

    private func configureSparkles(_ emitter: CAEmitterLayer) {
        let sparkleColors: [UIColor] = [
            UIColor.white,
            UIColor(hex: "#FFB347").withAlphaComponent(0.9),
            UIColor(hex: "#FF6347").withAlphaComponent(0.8),
            UIColor(hex: "#818CF8").withAlphaComponent(0.8),
        ]

        var cells: [CAEmitterCell] = []

        for (index, color) in sparkleColors.enumerated() {
            let cell = CAEmitterCell()
            cell.name = "sparkle_\(index)"
            cell.contents = makeCircleImage(diameter: 3)

            // Sparkles: fast fade, low gravity, random drift
            cell.birthRate = 15
            cell.lifetime = 1.5
            cell.lifetimeRange = 0.8
            cell.velocity = 30
            cell.velocityRange = 60
            cell.emissionLongitude = 0
            cell.emissionRange = 2 * .pi  // all directions

            cell.scale = 0.4
            cell.scaleRange = 0.3
            cell.scaleSpeed = -0.3         // shrink as they age

            cell.color = color.cgColor
            cell.alphaSpeed = -0.5         // quick fade
            cell.alphaRange = 0.2

            // Slight gravity so they don't just float endlessly
            cell.yAcceleration = 20

            cells.append(cell)
        }

        emitter.emitterCells = cells
    }

    // MARK: - Ambient Orbs Preset

    private func configureAmbientOrbs(_ emitter: CAEmitterLayer) {
        let orbColors: [UIColor] = [
            UIColor(hex: "#FF6347").withAlphaComponent(0.15),
            UIColor(hex: "#FFB347").withAlphaComponent(0.12),
            UIColor(hex: "#818CF8").withAlphaComponent(0.12),
        ]

        var cells: [CAEmitterCell] = []

        for (index, color) in orbColors.enumerated() {
            let cell = CAEmitterCell()
            cell.name = "orb_\(index)"
            // Large, soft image — radial gradient circle
            cell.contents = makeOrbImage(diameter: 120)

            // Very slow, long lived, low density
            cell.birthRate = 0.8
            cell.lifetime = 10.0
            cell.lifetimeRange = 4.0
            cell.velocity = 15
            cell.velocityRange = 10
            cell.emissionLongitude = 0
            cell.emissionRange = 2 * .pi

            // Large scale, varying so orbs overlap naturally
            cell.scale = 1.0
            cell.scaleRange = 1.5

            // Low alpha — these are atmospheric, not focal
            cell.color = color.cgColor
            cell.alphaSpeed = -0.015   // very slow fade
            cell.alphaRange = 0.05

            // No meaningful gravity — they drift
            cell.yAcceleration = 5

            cells.append(cell)
        }

        emitter.emitterCells = cells
    }
}

// MARK: - EmitterHostView
// Subclass lets us hold a weak reference to the emitter layer without storing
// it as an associated object, avoiding any retain-cycle risk.

private final class EmitterHostView: UIView {
    weak var emitterLayer: CAEmitterLayer?
}

// MARK: - Programmatic CGImage Factories
// All images are created via CoreGraphics at the smallest practical size.
// CAEmitterLayer will GPU-scale them — keeping source images tiny keeps
// the texture cache footprint minimal.

private func makeRectImage(width: CGFloat, height: CGFloat) -> CGImage? {
    let size = CGSize(width: max(width, 1), height: max(height, 1))
    let renderer = UIGraphicsImageRenderer(size: size)
    let image = renderer.image { ctx in
        ctx.cgContext.setFillColor(UIColor.white.cgColor)
        ctx.cgContext.fill(CGRect(origin: .zero, size: size))
    }
    return image.cgImage
}

private func makeCircleImage(diameter: CGFloat) -> CGImage? {
    let size = CGSize(width: diameter, height: diameter)
    let renderer = UIGraphicsImageRenderer(size: size)
    let image = renderer.image { ctx in
        ctx.cgContext.setFillColor(UIColor.white.cgColor)
        ctx.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
    }
    return image.cgImage
}

/// Creates a radial gradient circle suitable for the ambient orb preset.
/// White center → transparent edge. CAEmitterLayer tints it via cell.color.
private func makeOrbImage(diameter: CGFloat) -> CGImage? {
    let size = CGSize(width: diameter, height: diameter)
    let renderer = UIGraphicsImageRenderer(size: size)
    let image = renderer.image { rendererCtx in
        let ctx = rendererCtx.cgContext
        let center = CGPoint(x: diameter / 2, y: diameter / 2)
        let radius = diameter / 2

        guard let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [
                UIColor.white.cgColor,
                UIColor.white.withAlphaComponent(0).cgColor,
            ] as CFArray,
            locations: [0, 1]
        ) else { return }

        ctx.drawRadialGradient(
            gradient,
            startCenter: center,
            startRadius: 0,
            endCenter: center,
            endRadius: radius,
            options: []
        )
    }
    return image.cgImage
}

// MARK: - UIColor Hex Initializer (local, avoids dependency on VennDesignSystem)

private extension UIColor {
    convenience init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        let r, g, b: CGFloat
        switch cleaned.count {
        case 6:
            r = CGFloat((value >> 16) & 0xFF) / 255
            g = CGFloat((value >>  8) & 0xFF) / 255
            b = CGFloat( value        & 0xFF) / 255
        default:
            r = 1; g = 1; b = 1
        }
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}

// MARK: - Preview

struct ParticleEmitter_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ZStack {
                VennColors.darkBg.ignoresSafeArea()
                PremiumParticleEmitter(preset: .confetti, isEmitting: true, birthRate: 1.0)
                    .ignoresSafeArea()
                Text("Confetti")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .previewDisplayName("Confetti")

            ZStack {
                VennColors.darkBg.ignoresSafeArea()
                PremiumParticleEmitter(preset: .sparkles, isEmitting: true, birthRate: 1.0)
                    .ignoresSafeArea()
                Text("Sparkles")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .previewDisplayName("Sparkles")

            ZStack {
                VennColors.darkBg.ignoresSafeArea()
                PremiumParticleEmitter(preset: .ambientOrbs, isEmitting: true, birthRate: 1.0)
                    .ignoresSafeArea()
                Text("Ambient Orbs")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .previewDisplayName("Ambient Orbs")
        }
    }
}
