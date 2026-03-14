import Foundation
import SwiftUI

/// Global app state
/// Manages tab selection and app-wide state
class AppState: ObservableObject {
    @Published var selectedTab: Tab = .vivi // Default to Vivi (AI companion)
    
    enum Tab {
        case events
        case friends
        case vivi    // AI companion (center tab)
        case plans
        case profile
    }
}
