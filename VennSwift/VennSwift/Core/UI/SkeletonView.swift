import SwiftUI

/// Skeleton Loading View - Premium shimmer effect
/// Used for loading states with animated gradient
struct SkeletonView: View {
    @State private var phase: CGFloat = 0
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat
    
    init(width: CGFloat = 200, height: CGFloat = 20, cornerRadius: CGFloat = 8) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.05),
                        Color.white.opacity(0.12),
                        Color.white.opacity(0.05)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: width, height: height)
            .cornerRadius(cornerRadius)
            .mask(
                Rectangle()
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: phase - 0.3),
                                .init(color: .white, location: phase),
                                .init(color: .clear, location: phase + 0.3)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1.3
                }
            }
    }
}

/// Skeleton Event Card - Loading state for event cards
struct SkeletonEventCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image placeholder
            SkeletonView(width: 360, height: 240, cornerRadius: 20)
            
            VStack(alignment: .leading, spacing: 12) {
                // Date + location
                HStack(spacing: 12) {
                    SkeletonView(width: 80, height: 14, cornerRadius: 7)
                    SkeletonView(width: 100, height: 14, cornerRadius: 7)
                }
                
                // Title
                SkeletonView(width: 280, height: 24, cornerRadius: 8)
                SkeletonView(width: 200, height: 24, cornerRadius: 8)
                
                // Social proof
                HStack(spacing: 10) {
                    HStack(spacing: -8) {
                        ForEach(0..<3, id: \.self) { _ in
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 28, height: 28)
                        }
                    }
                    SkeletonView(width: 60, height: 16, cornerRadius: 8)
                }
            }
            .padding(20)
            .background(Color.white.opacity(0.03))
        }
        .frame(width: 360)
        .background(Color.white.opacity(0.05))
        .cornerRadius(24)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        VennColors.darkBg.ignoresSafeArea()
        
        VStack(spacing: 20) {
            SkeletonView(width: 200, height: 20)
            SkeletonView(width: 150, height: 16)
            
            SkeletonEventCard()
        }
        .padding()
    }
}
