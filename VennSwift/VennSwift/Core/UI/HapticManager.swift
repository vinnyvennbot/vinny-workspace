import UIKit

/// Haptic Feedback Manager
/// Provides tactile feedback for premium feel
@MainActor
class HapticManager {
    static let shared = HapticManager()
    
    private let light = UIImpactFeedbackGenerator(style: .light)
    private let medium = UIImpactFeedbackGenerator(style: .medium)
    private let heavy = UIImpactFeedbackGenerator(style: .heavy)
    private let soft = UIImpactFeedbackGenerator(style: .soft)
    private let rigid = UIImpactFeedbackGenerator(style: .rigid)
    private let selection = UISelectionFeedbackGenerator()
    private let notification = UINotificationFeedbackGenerator()
    
    private init() {
        // Prepare generators for minimal latency
        light.prepare()
        medium.prepare()
        selection.prepare()
    }
    
    // MARK: - Impact
    
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        switch style {
        case .light:
            light.impactOccurred()
            light.prepare()
        case .medium:
            medium.impactOccurred()
            medium.prepare()
        case .heavy:
            heavy.impactOccurred()
            heavy.prepare()
        case .soft:
            soft.impactOccurred()
            soft.prepare()
        case .rigid:
            rigid.impactOccurred()
            rigid.prepare()
        @unknown default:
            medium.impactOccurred()
            medium.prepare()
        }
    }
    
    // MARK: - Selection
    
    func selection() {
        selection.selectionChanged()
        selection.prepare()
    }
    
    // MARK: - Notification
    
    func success() {
        notification.notificationOccurred(.success)
        notification.prepare()
    }
    
    func warning() {
        notification.notificationOccurred(.warning)
        notification.prepare()
    }
    
    func error() {
        notification.notificationOccurred(.error)
        notification.prepare()
    }
}

// MARK: - View Extension

extension View {
    func hapticImpact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) -> some View {
        self.onTapGesture {
            Task { @MainActor in
                HapticManager.shared.impact(style)
            }
        }
    }
    
    func hapticSelection() -> some View {
        self.onChange(of: UUID()) { _, _ in
            Task { @MainActor in
                HapticManager.shared.selection()
            }
        }
    }
}
