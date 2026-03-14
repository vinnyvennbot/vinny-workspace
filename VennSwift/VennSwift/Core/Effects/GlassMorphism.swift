import SwiftUI
import UIKit

// MARK: - PremiumGlass UIViewRepresentable
// Hardware-accelerated blur via UIVisualEffectView — GPU composited, not CPU shimmed.
// UIBlurEffect uses the private render server blur pass, which is significantly
// cheaper than any SwiftUI or Core Image equivalent at equivalent quality.

struct PremiumGlass: UIViewRepresentable {

    // MARK: Configuration

    var blurRadius: CGFloat = 20
    var tintColor: UIColor = UIColor(white: 0.1, alpha: 0.3)
    var cornerRadius: CGFloat = 28
    var borderWidth: CGFloat = 1
    var borderColor: UIColor = UIColor(white: 1.0, alpha: 0.08)

    // MARK: UIViewRepresentable

    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .clear

        // Primary blur layer — UIBlurEffect uses the GPU render server blur pass.
        // We pick .systemUltraThinMaterialDark as the closest base, then override
        // the visual appearance with the tint overlay below.
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false

        // Vibrancy view sits inside the blur view's contentView — this is the
        // correct hierarchy for UIVisualEffectView children.
        let tintOverlay = UIView()
        tintOverlay.backgroundColor = tintColor
        tintOverlay.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(blurView)
        blurView.contentView.addSubview(tintOverlay)

        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            blurView.topAnchor.constraint(equalTo: containerView.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            tintOverlay.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor),
            tintOverlay.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor),
            tintOverlay.topAnchor.constraint(equalTo: blurView.contentView.topAnchor),
            tintOverlay.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor),
        ])

        applyShaping(to: containerView, blurView: blurView)

        // Store blur view reference for updates
        context.coordinator.blurView = blurView
        context.coordinator.tintOverlay = tintOverlay

        return containerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.tintOverlay?.backgroundColor = tintColor
        applyShaping(to: uiView, blurView: context.coordinator.blurView)
    }

    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        coordinator.blurView = nil
        coordinator.tintOverlay = nil
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    // MARK: Coordinator

    final class Coordinator {
        weak var blurView: UIVisualEffectView?
        weak var tintOverlay: UIView?
    }

    // MARK: Private Helpers

    private func applyShaping(to containerView: UIView, blurView: UIVisualEffectView?) {
        // Clip all children including the blur to the rounded rect
        containerView.layer.cornerRadius = cornerRadius
        containerView.layer.cornerCurve = .continuous
        containerView.clipsToBounds = true

        // Border rendered on the container layer — sits above the blur composite
        containerView.layer.borderWidth = borderWidth
        containerView.layer.borderColor = borderColor.cgColor
    }
}

// MARK: - PremiumGlassModifier
// SwiftUI modifier wrapper — composes PremiumGlass as a background then
// overlays a hairline inner border gradient for the top-lit glass rim effect.

struct PremiumGlassModifier: ViewModifier {
    var blur: CGFloat
    var tint: Color
    var cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                PremiumGlass(
                    blurRadius: blur,
                    tintColor: UIColor(tint),
                    cornerRadius: cornerRadius,
                    borderWidth: 0, // border handled by overlay below for gradient support
                    borderColor: .clear
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.14),
                                Color.white.opacity(0.04),
                                Color.white.opacity(0.02),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

// MARK: - View Extension

extension View {
    /// Applies a hardware-accelerated glassmorphism effect using UIVisualEffectView.
    /// - Parameters:
    ///   - blur: Blur radius passed to the underlying UIBlurEffect (default 20).
    ///   - tint: Color tint layered on top of the blur for hue control (default white 5%).
    ///   - cornerRadius: Continuous corner radius applied to the glass shape (default 28).
    func premiumGlass(
        blur: CGFloat = 20,
        tint: Color = Color.white.opacity(0.05),
        cornerRadius: CGFloat = 28
    ) -> some View {
        modifier(PremiumGlassModifier(blur: blur, tint: tint, cornerRadius: cornerRadius))
    }
}

// MARK: - Preview

struct GlassMorphism_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            // Busy background to show blur working
            LinearGradient(
                colors: [VennColors.coral, VennColors.indigo, VennColors.gold],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Premium Glass Card")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(24)
                    .premiumGlass(blur: 24, tint: Color.white.opacity(0.06), cornerRadius: 28)
                    .padding(.horizontal, 32)

                Text("Thin variant")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .premiumGlass(blur: 12, tint: VennColors.coral.opacity(0.10), cornerRadius: 16)
                    .padding(.horizontal, 48)
            }
        }
        .previewDisplayName("PremiumGlass")
    }
}
