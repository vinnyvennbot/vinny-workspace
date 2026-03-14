import SwiftUI

/// Micro Interactions - Delightful UI animations
/// Collection of advanced micro-animations for premium feel

// MARK: - Press Scale Animation

struct PressScaleModifier: ViewModifier {
    @Binding var isPressed: Bool
    let scale: CGFloat
    let haptic: UIImpactFeedbackGenerator.FeedbackStyle?
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? scale : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .onChange(of: isPressed) { newValue in
                if newValue, let haptic = haptic {
                    HapticManager.shared.impact(haptic)
                }
            }
    }
}

extension View {
    /// Apply press scale animation
    /// - Parameters:
    ///   - isPressed: Binding to press state
    ///   - scale: Target scale (default 0.95)
    ///   - haptic: Optional haptic feedback
    func pressScale(
        isPressed: Binding<Bool>,
        scale: CGFloat = 0.95,
        haptic: UIImpactFeedbackGenerator.FeedbackStyle? = .light
    ) -> some View {
        modifier(PressScaleModifier(isPressed: isPressed, scale: scale, haptic: haptic))
    }
}

// MARK: - Bounce Animation

struct BounceModifier: ViewModifier {
    let trigger: Bool
    @State private var bounce: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(1 + bounce)
            .onChange(of: trigger) { _ in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    bounce = 0.15
                }
                
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1)) {
                    bounce = 0
                }
            }
    }
}

extension View {
    /// Bounce animation on trigger change
    /// - Parameter trigger: Bool that triggers bounce
    func bounce(trigger: Bool) -> some View {
        modifier(BounceModifier(trigger: trigger))
    }
}

// MARK: - Shake Animation

struct ShakeModifier: ViewModifier {
    let trigger: Bool
    @State private var offset: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .offset(x: offset)
            .onChange(of: trigger) { _ in
                shakeAnimation()
            }
    }
    
    private func shakeAnimation() {
        let shakeIntensity: CGFloat = 10
        let shakeDuration: Double = 0.6
        let shakeCount = 3
        
        for i in 0..<shakeCount {
            let delay = Double(i) * (shakeDuration / Double(shakeCount))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.3)) {
                    offset = i % 2 == 0 ? shakeIntensity : -shakeIntensity
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + shakeDuration) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                offset = 0
            }
        }
        
        HapticManager.shared.impact(.medium)
    }
}

extension View {
    /// Shake animation (useful for errors)
    /// - Parameter trigger: Bool that triggers shake
    func shake(trigger: Bool) -> some View {
        modifier(ShakeModifier(trigger: trigger))
    }
}

// MARK: - Shimmer Effect

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    let duration: Double
    let offset: CGFloat
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                stops: [
                                    .init(color: .clear, location: 0),
                                    .init(color: .white.opacity(0.3), location: 0.5),
                                    .init(color: .clear, location: 1)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .rotationEffect(.degrees(-45))
                        .offset(x: phase * (geometry.size.width + offset) - offset)
                        .blendMode(.overlay)
                }
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    /// Add shimmer effect (loading indicator)
    /// - Parameters:
    ///   - duration: Animation duration
    ///   - offset: Shimmer width offset
    func shimmer(duration: Double = 2.0, offset: CGFloat = 200) -> some View {
        modifier(ShimmerModifier(duration: duration, offset: offset))
    }
}

// MARK: - Pulse Animation

struct PulseModifier: ViewModifier {
    @State private var scale: CGFloat = 1.0
    let minScale: CGFloat
    let maxScale: CGFloat
    let duration: Double
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                    scale = maxScale
                }
            }
    }
}

extension View {
    /// Pulse animation (breathing effect)
    /// - Parameters:
    ///   - from: Minimum scale
    ///   - to: Maximum scale
    ///   - duration: Animation duration
    func pulse(from minScale: CGFloat = 1.0, to maxScale: CGFloat = 1.1, duration: Double = 1.0) -> some View {
        modifier(PulseModifier(minScale: minScale, maxScale: maxScale, duration: duration))
    }
}

// MARK: - Wiggle Animation

struct WiggleModifier: ViewModifier {
    let trigger: Bool
    @State private var rotation: Double = 0
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(rotation))
            .onChange(of: trigger) { _ in
                wiggleAnimation()
            }
    }
    
    private func wiggleAnimation() {
        let wiggleDegrees: Double = 5
        let wiggleDuration: Double = 0.1
        let wiggleCount = 4
        
        for i in 0..<wiggleCount {
            let delay = Double(i) * wiggleDuration
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: wiggleDuration)) {
                    rotation = i % 2 == 0 ? wiggleDegrees : -wiggleDegrees
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(wiggleCount) * wiggleDuration) {
            withAnimation(.easeInOut(duration: wiggleDuration)) {
                rotation = 0
            }
        }
    }
}

extension View {
    /// Wiggle animation (playful shake)
    /// - Parameter trigger: Bool that triggers wiggle
    func wiggle(trigger: Bool) -> some View {
        modifier(WiggleModifier(trigger: trigger))
    }
}

// MARK: - Glow Effect

struct GlowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    let intensity: Double
    @State private var glowPhase: Double = 0
    
    func body(content: Content) -> some View {
        content
            .shadow(
                color: color.opacity(intensity * glowPhase),
                radius: radius * glowPhase,
                x: 0,
                y: 0
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    glowPhase = 1
                }
            }
    }
}

extension View {
    /// Add pulsing glow effect
    /// - Parameters:
    ///   - color: Glow color
    ///   - radius: Maximum glow radius
    ///   - intensity: Glow opacity (0-1)
    func glow(color: Color = .white, radius: CGFloat = 20, intensity: Double = 0.6) -> some View {
        modifier(GlowModifier(color: color, radius: radius, intensity: intensity))
    }
}

// MARK: - Floating Animation

struct FloatingModifier: ViewModifier {
    let range: CGFloat
    let duration: Double
    @State private var offset: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .offset(y: offset)
            .onAppear {
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                    offset = range
                }
            }
    }
}

extension View {
    /// Floating animation (vertical hover)
    /// - Parameters:
    ///   - range: Maximum offset distance
    ///   - duration: Animation duration
    func floating(range: CGFloat = 10, duration: Double = 2.0) -> some View {
        modifier(FloatingModifier(range: range, duration: duration))
    }
}

// MARK: - Preview

struct MicroInteractionsPreview: View {
    @State private var isPressed = false
    @State private var bounceCount = 0
    @State private var shakeCount = 0
    @State private var wiggleCount = 0
    
    var body: some View {
        ZStack {
            VennColors.darkBg.ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Press scale
                Button("Press Me") {
                    isPressed.toggle()
                }
                .pressScale(isPressed: $isPressed)
                .padding()
                .background(VennColors.coral)
                .foregroundColor(.white)
                .cornerRadius(12)
                
                // Bounce
                Text("Bounce")
                    .padding()
                    .background(VennColors.gold)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .bounce(trigger: bounceCount % 2 == 0)
                    .onTapGesture {
                        bounceCount += 1
                    }
                
                // Shake
                Text("Shake")
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shake(trigger: shakeCount % 2 == 0)
                    .onTapGesture {
                        shakeCount += 1
                    }
                
                // Shimmer
                Text("Shimmer")
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shimmer()
                
                // Pulse
                Text("Pulse")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .pulse()
                
                // Wiggle
                Text("Wiggle")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .wiggle(trigger: wiggleCount % 2 == 0)
                    .onTapGesture {
                        wiggleCount += 1
                    }
                
                // Glow
                Text("Glow")
                    .padding()
                    .background(Color.cyan)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .glow(color: .cyan, radius: 30)
                
                // Floating
                Circle()
                    .fill(VennColors.coral)
                    .frame(width: 50, height: 50)
                    .floating()
            }
        }
    }
}

#Preview {
    MicroInteractionsPreview()
}
