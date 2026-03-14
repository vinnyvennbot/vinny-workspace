import SwiftUI

/// Animated Button - Premium button with advanced animations
/// Features: Press states, loading, success/error states, haptics
struct AnimatedButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyle
    let state: ButtonState
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var scale: CGFloat = 1.0
    
    enum ButtonStyle {
        case primary, secondary, outline, danger, success
        
        var backgroundColor: LinearGradient {
            switch self {
            case .primary:
                return LinearGradient(
                    colors: [VennColors.coral, VennColors.gold],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            case .secondary:
                return LinearGradient(
                    colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            case .outline:
                return LinearGradient(
                    colors: [Color.clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            case .danger:
                return LinearGradient(
                    colors: [Color.red, Color.red.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            case .success:
                return LinearGradient(
                    colors: [Color.green, Color.green.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary, .danger, .success:
                return .white
            case .secondary:
                return VennColors.textPrimary
            case .outline:
                return VennColors.coral
            }
        }
    }
    
    enum ButtonState {
        case idle, loading, success, error
        
        var icon: String? {
            switch self {
            case .idle: return nil
            case .loading: return nil
            case .success: return "checkmark"
            case .error: return "xmark"
            }
        }
    }
    
    init(
        _ title: String,
        icon: String? = nil,
        style: ButtonStyle = .primary,
        state: ButtonState = .idle,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.state = state
        self.action = action
    }
    
    var body: some View {
        Button {
            handlePress()
        } label: {
            HStack(spacing: 10) {
                // State icon or custom icon
                if state == .loading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: style.foregroundColor))
                        .scaleEffect(0.9)
                } else if let stateIcon = state.icon {
                    Image(systemName: stateIcon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(style.foregroundColor)
                } else if let customIcon = icon {
                    Image(systemName: customIcon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(style.foregroundColor)
                }
                
                // Title
                Text(title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(style.foregroundColor)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                Capsule()
                    .fill(style.backgroundColor)
                    .overlay(
                        style == .outline
                            ? Capsule()
                                .stroke(VennColors.coral, lineWidth: 2)
                            : nil
                    )
                    .shadow(
                        color: shadowColor,
                        radius: isPressed ? 8 : 16,
                        y: isPressed ? 2 : 6
                    )
            )
        }
        .disabled(state == .loading)
        .scaleEffect(scale)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: scale)
        .onChange(of: isPressed) { newValue in
            scale = newValue ? 0.96 : 1.0
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .primary:
            return VennColors.coral.opacity(isPressed ? 0.2 : 0.4)
        case .danger:
            return Color.red.opacity(isPressed ? 0.2 : 0.4)
        case .success:
            return Color.green.opacity(isPressed ? 0.2 : 0.4)
        case .secondary, .outline:
            return .clear
        }
    }
    
    private func handlePress() {
        guard state != .loading else { return }
        
        HapticManager.shared.impact(.medium)
        
        withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
            isPressed = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = false
            }
            action()
        }
    }
}

/// Loading Button - Button with async/await loading state
struct LoadingButton<Content: View>: View {
    let action: () async -> Void
    let content: () -> Content
    
    @State private var isLoading = false
    
    init(
        action: @escaping () async -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.action = action
        self.content = content
    }
    
    var body: some View {
        Button {
            Task {
                await performAction()
            }
        } label: {
            ZStack {
                content()
                    .opacity(isLoading ? 0 : 1)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
        }
        .disabled(isLoading)
    }
    
    private func performAction() async {
        HapticManager.shared.impact(.medium)
        
        isLoading = true
        await action()
        isLoading = false
    }
}

/// Icon Button - Circular icon-only button
struct IconButton: View {
    let icon: String
    let size: CGFloat
    let backgroundColor: Color
    let foregroundColor: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    init(
        icon: String,
        size: CGFloat = 44,
        backgroundColor: Color = Color.white.opacity(0.1),
        foregroundColor: Color = .white,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.size = size
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.action = action
    }
    
    var body: some View {
        Button {
            HapticManager.shared.impact(.light)
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
                action()
            }
        } label: {
            Image(systemName: icon)
                .font(.system(size: size * 0.45, weight: .semibold))
                .foregroundColor(foregroundColor)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(backgroundColor)
                )
        }
        .scaleEffect(isPressed ? 0.9 : 1.0)
    }
}

/// Floating Action Button - Material Design style FAB
struct FloatingActionButton: View {
    let icon: String
    let size: CGFloat
    let action: () -> Void
    
    @State private var isPressed = false
    
    init(
        icon: String = "plus",
        size: CGFloat = 64,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button {
            HapticManager.shared.impact(.heavy)
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    isPressed = false
                }
                action()
            }
        } label: {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .bold))
                .foregroundColor(.white)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [VennColors.coral, VennColors.gold],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: VennColors.coral.opacity(0.5), radius: 20, y: 8)
                )
        }
        .scaleEffect(isPressed ? 0.85 : 1.0)
        .rotationEffect(.degrees(isPressed ? 90 : 0))
    }
}

// MARK: - Preview

struct AnimatedButtonPreview: View {
    @State private var buttonState: AnimatedButton.ButtonState = .idle
    
    var body: some View {
        ZStack {
            VennColors.darkBg.ignoresSafeArea()
            
            VStack(spacing: 20) {
                AnimatedButton("Primary Button", style: .primary) {
                    print("Primary tapped")
                }
                
                AnimatedButton("Secondary Button", style: .secondary) {
                    print("Secondary tapped")
                }
                
                AnimatedButton("Outline Button", style: .outline) {
                    print("Outline tapped")
                }
                
                AnimatedButton("Danger Button", style: .danger) {
                    print("Danger tapped")
                }
                
                AnimatedButton("Loading", style: .primary, state: .loading) {
                    print("Loading...")
                }
                
                AnimatedButton("Success", icon: "checkmark", style: .success, state: .success) {
                    print("Success!")
                }
                
                HStack(spacing: 20) {
                    IconButton(icon: "heart.fill") {
                        print("Like")
                    }
                    
                    IconButton(icon: "paperplane.fill") {
                        print("Send")
                    }
                    
                    IconButton(icon: "ellipsis") {
                        print("More")
                    }
                }
                
                FloatingActionButton {
                    print("FAB tapped")
                }
            }
            .padding()
        }
    }
}

#Preview {
    AnimatedButtonPreview()
}
