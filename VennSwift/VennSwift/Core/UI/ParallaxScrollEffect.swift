import SwiftUI

/// Parallax Scroll Effect - Advanced depth scrolling
/// Creates depth illusion with different scroll speeds per layer
struct ParallaxScrollEffect: ViewModifier {
    let speed: CGFloat
    @Binding var scrollOffset: CGFloat
    
    func body(content: Content) -> some View {
        content
            .offset(y: -scrollOffset * speed)
    }
}

extension View {
    /// Apply parallax effect based on scroll offset
    /// - Parameters:
    ///   - speed: Parallax multiplier (0.5 = half speed, 2.0 = double speed)
    ///   - scrollOffset: Binding to scroll offset
    func parallax(speed: CGFloat = 0.5, scrollOffset: Binding<CGFloat>) -> some View {
        modifier(ParallaxScrollEffect(speed: speed, scrollOffset: scrollOffset))
    }
}

/// Scroll Scale Effect - Scale views based on scroll position
struct ScrollScaleEffect: ViewModifier {
    let minScale: CGFloat
    let maxScale: CGFloat
    let scrollThreshold: CGFloat
    @Binding var scrollOffset: CGFloat
    
    func body(content: Content) -> some View {
        let progress = min(max(scrollOffset / scrollThreshold, 0), 1)
        let scale = minScale + (maxScale - minScale) * (1 - progress)
        
        return content
            .scaleEffect(scale)
    }
}

extension View {
    /// Scale view based on scroll position
    /// - Parameters:
    ///   - minScale: Minimum scale value
    ///   - maxScale: Maximum scale value
    ///   - threshold: Scroll distance for full scale transition
    ///   - scrollOffset: Binding to scroll offset
    func scrollScale(
        from minScale: CGFloat = 0.8,
        to maxScale: CGFloat = 1.0,
        threshold: CGFloat = 200,
        scrollOffset: Binding<CGFloat>
    ) -> some View {
        modifier(ScrollScaleEffect(
            minScale: minScale,
            maxScale: maxScale,
            scrollThreshold: threshold,
            scrollOffset: scrollOffset
        ))
    }
}

/// Scroll Blur Effect - Blur content based on scroll velocity
struct ScrollBlurEffect: ViewModifier {
    let maxBlur: CGFloat
    @Binding var scrollVelocity: CGFloat
    
    func body(content: Content) -> some View {
        let blur = min(abs(scrollVelocity) / 1000, 1) * maxBlur
        
        return content
            .blur(radius: blur)
    }
}

extension View {
    /// Apply blur based on scroll velocity
    /// - Parameters:
    ///   - maxBlur: Maximum blur radius
    ///   - scrollVelocity: Binding to scroll velocity
    func scrollBlur(maxBlur: CGFloat = 5, scrollVelocity: Binding<CGFloat>) -> some View {
        modifier(ScrollBlurEffect(maxBlur: maxBlur, scrollVelocity: scrollVelocity))
    }
}

/// Scroll Fade Effect - Fade elements based on scroll position
struct ScrollFadeEffect: ViewModifier {
    let fadeRange: ClosedRange<CGFloat>
    @Binding var scrollOffset: CGFloat
    
    func body(content: Content) -> some View {
        let progress: CGFloat
        
        if scrollOffset <= fadeRange.lowerBound {
            progress = 1
        } else if scrollOffset >= fadeRange.upperBound {
            progress = 0
        } else {
            let range = fadeRange.upperBound - fadeRange.lowerBound
            progress = 1 - ((scrollOffset - fadeRange.lowerBound) / range)
        }
        
        return content
            .opacity(progress)
    }
}

extension View {
    /// Fade view based on scroll position
    /// - Parameters:
    ///   - fadeRange: Scroll offset range for fade transition (0...200 = fade from 0 to 200)
    ///   - scrollOffset: Binding to scroll offset
    func scrollFade(fadeRange: ClosedRange<CGFloat>, scrollOffset: Binding<CGFloat>) -> some View {
        modifier(ScrollFadeEffect(fadeRange: fadeRange, scrollOffset: scrollOffset))
    }
}

/// Sticky Header Effect - Pin header after threshold
struct StickyHeaderEffect: ViewModifier {
    let threshold: CGFloat
    @Binding var scrollOffset: CGFloat
    
    func body(content: Content) -> some View {
        content
            .offset(y: scrollOffset > threshold ? threshold - scrollOffset : 0)
    }
}

extension View {
    /// Create sticky header that pins after threshold
    /// - Parameters:
    ///   - threshold: Scroll offset at which to pin
    ///   - scrollOffset: Binding to scroll offset
    func stickyHeader(threshold: CGFloat = 0, scrollOffset: Binding<CGFloat>) -> some View {
        modifier(StickyHeaderEffect(threshold: threshold, scrollOffset: scrollOffset))
    }
}

// MARK: - Example Usage

struct ParallaxScrollEffectExample: View {
    @State private var scrollOffset: CGFloat = 0
    @State private var scrollVelocity: CGFloat = 0
    
    var body: some View {
        ZStack {
            VennColors.darkBg.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Background layer (slower parallax)
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [VennColors.coral.opacity(0.3), VennColors.gold.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 400)
                        .parallax(speed: 0.3, scrollOffset: $scrollOffset)
                    
                    // Content
                    VStack(spacing: 20) {
                        ForEach(0..<10) { i in
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.05))
                                .frame(height: 100)
                                .scrollScale(
                                    from: 0.9,
                                    to: 1.0,
                                    threshold: 200,
                                    scrollOffset: $scrollOffset
                                )
                                .scrollFade(fadeRange: 400...600, scrollOffset: $scrollOffset)
                        }
                    }
                    .padding()
                }
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).minY)
                    }
                )
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
            }
            
            // Debug info
            VStack {
                HStack {
                    Text("Offset: \(Int(scrollOffset))")
                        .foregroundColor(.white)
                        .padding()
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

#Preview {
    ParallaxScrollEffectExample()
}
