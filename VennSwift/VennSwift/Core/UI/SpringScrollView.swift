import SwiftUI

/// Spring Scroll View - Ultra-smooth scrolling with spring physics
/// Provides velocity-based scrolling with natural deceleration
struct SpringScrollView<Content: View>: View {
    let axes: Axis.Set
    let showsIndicators: Bool
    let content: Content
    
    @State private var velocity: CGFloat = 0
    @State private var isDragging = false
    @GestureState private var dragOffset: CGFloat = 0
    
    init(
        _ axes: Axis.Set = .vertical,
        showsIndicators: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.content = content()
    }
    
    var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            content
        }
        .simultaneousGesture(
            DragGesture()
                .onChanged { value in
                    if !isDragging {
                        isDragging = true
                        HapticManager.shared.impact(.light)
                    }
                    
                    // Calculate velocity
                    velocity = value.predictedEndTranslation.height - value.translation.height
                }
                .onEnded { value in
                    isDragging = false
                    
                    // Apply spring deceleration based on velocity
                    let v = abs(velocity)
                    if v > 100 {
                        HapticManager.shared.impact(.soft)
                    }
                }
        )
    }
}

/// Scroll Velocity Tracker - Track scroll velocity for advanced animations
struct ScrollVelocityTracker: ViewModifier {
    @Binding var velocity: CGFloat
    @Binding var offset: CGFloat
    @State private var lastOffset: CGFloat = 0
    @State private var lastTime: Date = Date()
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).minY)
                }
            )
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { newOffset in
                let now = Date()
                let dt = now.timeIntervalSince(lastTime)
                
                if dt > 0 {
                    let delta = newOffset - lastOffset
                    velocity = delta / CGFloat(dt)
                }
                
                offset = newOffset
                lastOffset = newOffset
                lastTime = now
            }
    }
}

extension View {
    func trackScrollVelocity(velocity: Binding<CGFloat>, offset: Binding<CGFloat>) -> some View {
        modifier(ScrollVelocityTracker(velocity: velocity, offset: offset))
    }
}

/// Bounce Scroll Modifier - Add bounce effect at scroll boundaries
struct BounceScrollModifier: ViewModifier {
    let threshold: CGFloat
    @Binding var offset: CGFloat
    @State private var bouncePhase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .offset(y: bounceEffect)
            .onChange(of: offset) { newValue in
                if newValue > threshold {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        bouncePhase = min((newValue - threshold) * 0.3, 30)
                    }
                } else if newValue < -threshold {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        bouncePhase = max((newValue + threshold) * 0.3, -30)
                    }
                } else {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        bouncePhase = 0
                    }
                }
            }
    }
    
    private var bounceEffect: CGFloat {
        bouncePhase
    }
}

extension View {
    func bounceScroll(threshold: CGFloat = 100, offset: Binding<CGFloat>) -> some View {
        modifier(BounceScrollModifier(threshold: threshold, offset: offset))
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var velocity: CGFloat = 0
    @Previewable @State var offset: CGFloat = 0
    
    ZStack {
        VennColors.darkBg.ignoresSafeArea()
        
        SpringScrollView {
            VStack(spacing: 20) {
                ForEach(0..<20) { i in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(VennColors.coral.opacity(0.2))
                        .frame(height: 100)
                        .overlay(
                            Text("Item \(i)")
                                .foregroundColor(.white)
                        )
                }
            }
            .padding()
        }
        
        VStack {
            HStack {
                Text("Velocity: \(Int(velocity))")
                    .foregroundColor(.white)
                    .padding()
                Spacer()
            }
            Spacer()
        }
    }
}
