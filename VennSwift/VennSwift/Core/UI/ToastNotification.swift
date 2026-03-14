import SwiftUI

/// Toast Notification - Premium notification system
/// Displays temporary notifications with animations and haptics

// MARK: - Toast Model

struct Toast: Identifiable, Equatable {
    let id = UUID()
    let message: String
    let type: ToastType
    let duration: Double
    let haptic: UINotificationFeedbackGenerator.FeedbackType?
    
    enum ToastType {
        case success, error, warning, info
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .info: return "info.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .success: return .green
            case .error: return .red
            case .warning: return .orange
            case .info: return VennColors.coral
            }
        }
    }
    
    init(
        message: String,
        type: ToastType = .info,
        duration: Double = 3.0,
        haptic: UINotificationFeedbackGenerator.FeedbackType? = nil
    ) {
        self.message = message
        self.type = type
        self.duration = duration
        self.haptic = haptic
    }
}

// MARK: - Toast View

struct ToastView: View {
    let toast: Toast
    let onDismiss: () -> Void
    
    @State private var offset: CGFloat = -200
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.8
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: toast.type.icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(toast.type.color)
            
            // Message
            Text(toast.message)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(2)
            
            Spacer(minLength: 0)
            
            // Dismiss button
            Button {
                dismissToast()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(toast.type.color.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
        )
        .padding(.horizontal, 20)
        .offset(y: offset)
        .opacity(opacity)
        .scaleEffect(scale)
        .onAppear {
            presentToast()
        }
    }
    
    private func presentToast() {
        // Haptic feedback
        if let haptic = toast.haptic {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(haptic)
        } else {
            HapticManager.shared.impact(.light)
        }
        
        // Animate in
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            offset = 0
            opacity = 1
            scale = 1.0
        }
        
        // Auto dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration) {
            dismissToast()
        }
    }
    
    private func dismissToast() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            offset = -200
            opacity = 0
            scale = 0.9
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}

// MARK: - Toast Manager

@MainActor
class ToastManager: ObservableObject {
    static let shared = ToastManager()
    
    @Published var toasts: [Toast] = []
    
    private init() {}
    
    func show(
        _ message: String,
        type: Toast.ToastType = .info,
        duration: Double = 3.0,
        haptic: UINotificationFeedbackGenerator.FeedbackType? = nil
    ) {
        let toast = Toast(message: message, type: type, duration: duration, haptic: haptic)
        toasts.append(toast)
    }
    
    func showSuccess(_ message: String, duration: Double = 3.0) {
        show(message, type: .success, duration: duration, haptic: .success)
    }
    
    func showError(_ message: String, duration: Double = 3.0) {
        show(message, type: .error, duration: duration, haptic: .error)
    }
    
    func showWarning(_ message: String, duration: Double = 3.0) {
        show(message, type: .warning, duration: duration, haptic: .warning)
    }
    
    func showInfo(_ message: String, duration: Double = 3.0) {
        show(message, type: .info, duration: duration)
    }
    
    func dismiss(_ toast: Toast) {
        toasts.removeAll { $0.id == toast.id }
    }
    
    func dismissAll() {
        toasts.removeAll()
    }
}

// MARK: - Toast Container

struct ToastContainer: View {
    @StateObject private var manager = ToastManager.shared
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(manager.toasts) { toast in
                ToastView(toast: toast) {
                    manager.dismiss(toast)
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity).combined(with: .scale),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
            }
        }
        .padding(.top, 60)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: manager.toasts)
    }
}

// MARK: - View Modifier

struct ToastModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            content
            
            VStack {
                ToastContainer()
                Spacer()
            }
        }
    }
}

extension View {
    func withToasts() -> some View {
        modifier(ToastModifier())
    }
}

// MARK: - Convenience Extension

extension View {
    func toast(
        _ message: String,
        type: Toast.ToastType = .info,
        duration: Double = 3.0,
        haptic: UINotificationFeedbackGenerator.FeedbackType? = nil
    ) -> some View {
        Task { @MainActor in
            ToastManager.shared.show(message, type: type, duration: duration, haptic: haptic)
        }
        return self
    }
    
    func successToast(_ message: String, duration: Double = 3.0) -> some View {
        Task { @MainActor in
            ToastManager.shared.showSuccess(message, duration: duration)
        }
        return self
    }
    
    func errorToast(_ message: String, duration: Double = 3.0) -> some View {
        Task { @MainActor in
            ToastManager.shared.showError(message, duration: duration)
        }
        return self
    }
}

// MARK: - Preview

struct ToastPreview: View {
    var body: some View {
        ZStack {
            VennColors.darkBg.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Button("Show Success") {
                    ToastManager.shared.showSuccess("Event saved successfully!")
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(12)
                
                Button("Show Error") {
                    ToastManager.shared.showError("Failed to load events")
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(12)
                
                Button("Show Warning") {
                    ToastManager.shared.showWarning("Network connection unstable")
                }
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(12)
                
                Button("Show Info") {
                    ToastManager.shared.showInfo("New events available")
                }
                .padding()
                .background(VennColors.coral)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
        .withToasts()
    }
}

#Preview {
    ToastPreview()
}
