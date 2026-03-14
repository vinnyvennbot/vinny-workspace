import Foundation
import SwiftUI

class AppState: ObservableObject {
    @Published var selectedTab: Tab = .vivi

    enum Tab: Int, CaseIterable {
        case events = 0
        case friends
        case vivi
        case plans
        case profile

        var title: String {
            switch self {
            case .events:  return "Discover"
            case .friends: return "Friends"
            case .vivi:    return "Vivi"
            case .plans:   return "Plans"
            case .profile: return "Profile"
            }
        }

        var icon: String {
            switch self {
            case .events:  return "sparkles"
            case .friends: return "person.2.fill"
            case .vivi:    return "wand.and.stars"
            case .plans:   return "calendar"
            case .profile: return "person.crop.circle"
            }
        }
    }
}
