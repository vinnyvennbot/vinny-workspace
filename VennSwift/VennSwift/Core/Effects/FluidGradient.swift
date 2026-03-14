import SwiftUI
import UIKit
import QuartzCore

// MARK: - FluidGradientView
// Fluid "lava lamp" gradient composed of multiple radial CAGradientLayer blobs,
// each independently animated along a unique Lissajous-curve path.
// The entire composition runs on the GPU render server via Core Animation —
// no SwiftUI animation driver is involved at runtime.

struct FluidGradientView: UIViewRepresentable {

    // MARK: Configuration

    var colors: [Color] = [VennColors.coral, VennColors.gold, VennColors.indigo]
    /// Animation speed multiplier — 1.0 is a comfortable 8-second cycle.
    var speed: CGFloat = 1.0
    /// Gaussian blur radius applied to the blob layer (creates the soft blending).
    var blur: CGFloat = 60

    // MARK: UIViewRepresentable

    func makeUIView(context: Context) -> UIView {
        let view = FluidGradientHostView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let view = uiView as? FluidGradientHostView else { return }
        // Rebuild blobs whenever configuration changes
        view.configure(colors: colors.map(\.uiColor), speed: speed, blur: blur)
    }

    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        guard let view = uiView as? FluidGradientHostView else { return }
        view.tearDown()
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    // MARK: Coordinator

    final class Coordinator {}
}

// MARK: - FluidGradientHostView
// Owns the CAGradientLayer blobs and their animations. Separated from the
// UIViewRepresentable to keep lifecycle clear.

private final class FluidGradientHostView: UIView {

    // MARK: State

    private var blobLayers: [CAGradientLayer] = []
    private var blurLayer: CALayer?

    // MARK: Public Interface

    func configure(colors: [UIColor], speed: CGFloat, blur: CGFloat) {
        tearDown()

        guard !colors.isEmpty else { return }

        let blobContainer = CALayer()
        blobContainer.frame = bounds.isEmpty
            ? CGRect(origin: .zero, size: UIScreen.main.bounds.size)
            : bounds

        // Build one radial blob per color
        let blobColors = colors.count < 4 ? colors + Array(colors.prefix(4 - colors.count)) : Array(colors.prefix(4))
        for (index, color) in blobColors.enumerated() {
            let blob = makeBlob(color: color, parentBounds: blobContainer.bounds, index: index)
            blobContainer.addSublayer(blob)
            blobLayers.append(blob)

            // Each blob gets an independent Lissajous path animation
            addBlobAnimation(to: blob, index: index, speed: speed, parentBounds: blobContainer.bounds)
        }

        layer.addSublayer(blobContainer)

        // Gaussian blur applied via layer filter — composited on the GPU.
        // We use a CIFilter rather than a Metal pass because CIFilter blur on
        // a CALayer is automatically offloaded to the render server.
        applyBlur(to: blobContainer, radius: blur)

        self.blurLayer = blobContainer
    }

    func tearDown() {
        blobLayers.forEach { $0.removeAllAnimations(); $0.removeFromSuperlayer() }
        blobLayers = []
        blurLayer?.removeFromSuperlayer()
        blurLayer = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Keep the blob container filling the view as bounds change
        blurLayer?.frame = bounds
        for (index, blob) in blobLayers.enumerated() {
            blob.bounds = CGRect(origin: .zero, size: blobSize(for: bounds))
            // Repositioning is handled by the running animation — no manual reset needed
        }
    }

    // MARK: Blob Factory

    private func makeBlob(color: UIColor, parentBounds: CGRect, index: Int) -> CAGradientLayer {
        let blob = CAGradientLayer()
        blob.type = .radial

        // Radial gradient: opaque color in center, fully transparent at edge.
        // The alpha falloff is what gives us the soft lava-lamp merge at overlap zones.
        blob.colors = [
            color.withAlphaComponent(0.85).cgColor,
            color.withAlphaComponent(0.30).cgColor,
            color.withAlphaComponent(0.0).cgColor,
        ]
        blob.locations = [0, 0.5, 1.0]

        // CAGradientLayer radial startPoint is the center, endPoint defines the radius.
        // We use [0, 0] → [1, 1] which gives a circular gradient spanning the full layer.
        blob.startPoint = CGPoint(x: 0.5, y: 0.5)
        blob.endPoint   = CGPoint(x: 1.0, y: 1.0)

        let size = blobSize(for: parentBounds)
        blob.bounds = CGRect(origin: .zero, size: size)
        blob.position = initialPosition(for: index, parentBounds: parentBounds)

        return blob
    }

    private func blobSize(for parentBounds: CGRect) -> CGSize {
        // Each blob covers ~80% of the view dimension so overlap occurs naturally
        let dimension = max(parentBounds.width, parentBounds.height) * 0.80
        return CGSize(width: dimension, height: dimension)
    }

    private func initialPosition(for index: Int, parentBounds: CGRect) -> CGPoint {
        // Distribute blobs at 90-degree rotations around the center
        let angle = CGFloat(index) * (.pi / 2)
        let radius = min(parentBounds.width, parentBounds.height) * 0.25
        return CGPoint(
            x: parentBounds.midX + radius * cos(angle),
            y: parentBounds.midY + radius * sin(angle)
        )
    }

    // MARK: Lissajous Animation

    /// Animates a blob along a Lissajous figure-8 path using CAKeyframeAnimation.
    /// Each blob gets different frequency ratios so they never move in sync.
    private func addBlobAnimation(
        to blob: CAGradientLayer,
        index: Int,
        speed: CGFloat,
        parentBounds: CGRect
    ) {
        // Lissajous parameters — (a, b) frequency ratios produce different curve shapes
        let params: [(a: Double, b: Double, phaseOffset: Double)] = [
            (a: 1, b: 2, phaseOffset: 0),
            (a: 2, b: 3, phaseOffset: .pi / 4),
            (a: 3, b: 4, phaseOffset: .pi / 3),
            (a: 1, b: 3, phaseOffset: .pi / 6),
        ]
        let p = params[index % params.count]

        // Sample the Lissajous curve at evenly-spaced parameter values
        let sampleCount = 120
        var positions: [CGPoint] = []

        let rx = parentBounds.width  * 0.35
        let ry = parentBounds.height * 0.35
        let cx = parentBounds.midX
        let cy = parentBounds.midY

        for i in 0...sampleCount {
            let t = Double(i) / Double(sampleCount) * 2 * .pi
            let x = cx + rx * cos(p.a * t + p.phaseOffset)
            let y = cy + ry * sin(p.b * t)
            positions.append(CGPoint(x: x, y: y))
        }

        let anim = CAKeyframeAnimation(keyPath: "position")
        anim.values = positions.map { NSValue(cgPoint: $0) }
        anim.calculationMode = .cubic   // smooth cubic interpolation between samples
        anim.duration = (8.0 + Double(index) * 1.5) / Double(speed > 0 ? speed : 0.01)
        anim.repeatCount = .infinity
        anim.isRemovedOnCompletion = false

        blob.add(anim, forKey: "lissajousPath_\(index)")
    }

    // MARK: Blur Filter

    private func applyBlur(to targetLayer: CALayer, radius: CGFloat) {
        guard radius > 0 else { return }
        // layer.filters accepts CIFilter objects — Core Animation drives them on the GPU.
        let blurFilter = CIFilter(name: "CIGaussianBlur")
        blurFilter?.setValue(radius, forKey: kCIInputRadiusKey)
        targetLayer.filters = blurFilter.map { [$0] } ?? []
        // Expand the layer frame by the blur radius on all sides to prevent
        // the hard transparent edge from showing through at the view boundary.
        let expansion = radius * 2
        targetLayer.frame = targetLayer.frame.insetBy(dx: -expansion, dy: -expansion)
    }
}

// MARK: - Color Utility

private extension Color {
    var uiColor: UIColor { UIColor(self) }
}

// MARK: - View Modifier Extension

extension View {
    /// Overlays a fluid animated gradient background behind this view.
    /// - Parameters:
    ///   - colors: Gradient blob colors (3-4 recommended for best visual mixing).
    ///   - speed: Animation speed multiplier relative to the default 8-second cycle.
    ///   - blur: Gaussian blur radius controlling how soft the blob edges are.
    func fluidGradientBackground(
        colors: [Color] = [VennColors.coral, VennColors.gold, VennColors.indigo],
        speed: CGFloat = 1.0,
        blur: CGFloat = 60
    ) -> some View {
        background(
            FluidGradientView(colors: colors, speed: speed, blur: blur)
        )
    }
}

// MARK: - Preview

struct FluidGradient_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ZStack {
                VennColors.darkBg.ignoresSafeArea()
                FluidGradientView(
                    colors: [VennColors.coral, VennColors.gold, VennColors.indigo],
                    speed: 1.0,
                    blur: 60
                )
                .ignoresSafeArea()
                Text("Fluid Gradient")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .previewDisplayName("Default")

            ZStack {
                VennColors.darkBg.ignoresSafeArea()
                FluidGradientView(
                    colors: [VennColors.coral, VennColors.indigo],
                    speed: 3.0,
                    blur: 80
                )
                .ignoresSafeArea()
                Text("Fast Mode")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .previewDisplayName("Fast")
        }
    }
}
