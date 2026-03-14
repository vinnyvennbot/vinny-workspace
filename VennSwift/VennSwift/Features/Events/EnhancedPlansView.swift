import SwiftUI

/// Enhanced Plans View - Upcoming events calendar
/// Features: Calendar view, RSVP'd events, invites, past events
struct EnhancedPlansView: View {
    @StateObject private var viewModel = PlansViewModel()
    @State private var scrollOffset: CGFloat = 0
    @State private var selectedTab: PlanTab = .upcoming
    @State private var selectedDate: Date = Date()
    
    enum PlanTab: String, CaseIterable {
        case upcoming = "Upcoming"
        case invites = "Invites"
        case past = "Past"
        
        var icon: String {
            switch self {
            case .upcoming: return "calendar"
            case .invites: return "envelope.badge"
            case .past: return "clock.arrow.circlepath"
            }
        }
    }
    
    var body: some View {
        ZStack {
            VennColors.darkBg.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                plansHeader
                
                // Tab selector
                tabSelector
                
                // Content based on selected tab
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 16) {
                        switch selectedTab {
                        case .upcoming:
                            upcomingSection
                        case .invites:
                            invitesSection
                        case .past:
                            pastSection
                        }
                    }
                    .padding(.horizontal, VennSpacing.lg)
                    .padding(.top, VennSpacing.md)
                    .padding(.bottom, 100)
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
            }
        }
        .withToasts()
    }
    
    // MARK: - Header
    
    private var plansHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Text("My Plans")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Calendar icon
                Button {
                    HapticManager.shared.impact(.light)
                    ToastManager.shared.showInfo("Calendar view coming soon!")
                } label: {
                    Image(systemName: "calendar")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(VennColors.textTertiary)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                        )
                }
            }
            
            // Quick stats
            HStack(spacing: 20) {
                statPill(count: viewModel.upcomingEvents.count, label: "Upcoming", color: VennColors.coral)
                statPill(count: viewModel.invites.count, label: "Invites", color: VennColors.gold)
                statPill(count: viewModel.pastEvents.count, label: "Attended", color: .green)
            }
        }
        .padding(.horizontal, VennSpacing.xl)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }
    
    private func statPill(count: Int, label: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Text("\(count)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(VennColors.textSecondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Tab Selector
    
    private var tabSelector: some View {
        HStack(spacing: 8) {
            ForEach(PlanTab.allCases, id: \.self) { tab in
                Button {
                    HapticManager.shared.impact(.light)
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 13, weight: .bold))
                        
                        Text(tab.rawValue)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(selectedTab == tab ? .white : VennColors.textTertiary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(
                                selectedTab == tab
                                    ? LinearGradient(
                                        colors: [VennColors.coral, VennColors.gold],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                    : LinearGradient(
                                        colors: [Color.white.opacity(0.05)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                            )
                    )
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, VennSpacing.xl)
        .padding(.vertical, 8)
    }
    
    // MARK: - Upcoming Section
    
    private var upcomingSection: some View {
        Group {
            if viewModel.upcomingEvents.isEmpty {
                emptyState(
                    icon: "calendar.badge.exclamationmark",
                    title: "No upcoming events",
                    message: "Start exploring events to fill your calendar"
                )
            } else {
                ForEach(Array(viewModel.upcomingEvents.enumerated()), id: \.element.id) { index, event in
                    EnhancedPlanCard(event: event, index: index, type: .upcoming)
                }
            }
        }
    }
    
    // MARK: - Invites Section
    
    private var invitesSection: some View {
        Group {
            if viewModel.invites.isEmpty {
                emptyState(
                    icon: "envelope.open",
                    title: "No pending invites",
                    message: "Event invitations from friends will appear here"
                )
            } else {
                ForEach(Array(viewModel.invites.enumerated()), id: \.element.id) { index, event in
                    EnhancedPlanCard(event: event, index: index, type: .invite)
                }
            }
        }
    }
    
    // MARK: - Past Section
    
    private var pastSection: some View {
        Group {
            if viewModel.pastEvents.isEmpty {
                emptyState(
                    icon: "clock.arrow.circlepath",
                    title: "No past events",
                    message: "Events you've attended will show up here"
                )
            } else {
                ForEach(Array(viewModel.pastEvents.enumerated()), id: \.element.id) { index, event in
                    EnhancedPlanCard(event: event, index: index, type: .past)
                }
            }
        }
    }
    
    // MARK: - Empty State
    
    private func emptyState(icon: String, title: String, message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60, weight: .light))
                .foregroundColor(VennColors.textTertiary)
                .padding(.top, 80)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(message)
                    .font(.system(size: 15))
                    .foregroundColor(VennColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: - Plan Card

struct EnhancedPlanCard: View {
    let event: PlanEvent
    let index: Int
    let type: CardType
    
    enum CardType {
        case upcoming, invite, past
    }
    
    @State private var appeared = false
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Event image placeholder
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            VennColors.coral.opacity(0.3),
                            VennColors.gold.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 160)
                .overlay(
                    // Date badge
                    VStack {
                        HStack {
                            dateBadge
                            Spacer()
                        }
                        .padding(12)
                        Spacer()
                    }
                )
            
            // Content
            VStack(alignment: .leading, spacing: 12) {
                // Title
                Text(event.name)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                // Location + time
                HStack(spacing: 14) {
                    Label(event.location, systemImage: "mappin.circle.fill")
                    Label(event.time, systemImage: "clock.fill")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(VennColors.textSecondary)
                
                // Attendees
                if event.attendees > 0 {
                    HStack(spacing: -8) {
                        ForEach(0..<min(4, event.attendees), id: \.self) { _ in
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [VennColors.coral, VennColors.gold],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(VennColors.darkBg, lineWidth: 2)
                                )
                        }
                        
                        if event.attendees > 4 {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Text("+\(event.attendees - 4)")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white)
                                )
                        }
                        
                        Text("\(event.attendees) going")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(VennColors.coral)
                            .padding(.leading, 12)
                    }
                }
                
                // Action buttons
                actionButtons
            }
            .padding(16)
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .pressScale(isPressed: $isPressed, scale: 0.98)
        .onTapGesture {
            isPressed.toggle()
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 30)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75).delay(Double(index) * 0.06)) {
                appeared = true
            }
        }
    }
    
    private var dateBadge: some View {
        VStack(spacing: 2) {
            Text(event.month.uppercased())
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white.opacity(0.9))
            
            Text("\(event.day)")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    @ViewBuilder
    private var actionButtons: some View {
        switch type {
        case .upcoming:
            HStack(spacing: 10) {
                Button {
                    HapticManager.shared.impact(.light)
                    ToastManager.shared.showInfo("Event details coming soon!")
                } label: {
                    Text("View Details")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [VennColors.coral, VennColors.gold],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                }
                
                Button {
                    HapticManager.shared.impact(.light)
                    ToastManager.shared.showInfo("Add to calendar coming soon!")
                } label: {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(VennColors.textTertiary)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                        )
                }
            }
            
        case .invite:
            HStack(spacing: 10) {
                Button {
                    HapticManager.shared.success()
                    ToastManager.shared.showSuccess("Accepted invitation!")
                } label: {
                    Text("Accept")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color.green)
                        )
                }
                
                Button {
                    HapticManager.shared.impact(.light)
                    ToastManager.shared.showInfo("Declined invitation")
                } label: {
                    Text("Decline")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .stroke(Color.red.opacity(0.3), lineWidth: 1.5)
                        )
                }
            }
            
        case .past:
            Button {
                HapticManager.shared.impact(.light)
                ToastManager.shared.showInfo("Event memories coming soon!")
            } label: {
                Text("View Photos")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(VennColors.textTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
                    )
            }
        }
    }
}

// MARK: - Plan Event Model

struct PlanEvent: Identifiable {
    let id = UUID()
    let name: String
    let location: String
    let time: String
    let day: Int
    let month: String
    let attendees: Int
    let isInvite: Bool
    let isPast: Bool
}

// MARK: - View Model

@MainActor
class PlansViewModel: ObservableObject {
    @Published var upcomingEvents: [PlanEvent] = []
    @Published var invites: [PlanEvent] = []
    @Published var pastEvents: [PlanEvent] = []
    
    init() {
        loadMockPlans()
    }
    
    private func loadMockPlans() {
        upcomingEvents = [
            PlanEvent(name: "Venn Club Dinner", location: "The Barrel Room", time: "7:00 PM", day: 28, month: "Feb", attendees: 17, isInvite: false, isPast: false),
            PlanEvent(name: "80s/90s Nostalgia Night", location: "TBD", time: "9:00 PM", day: 15, month: "Mar", attendees: 29, isInvite: false, isPast: false),
            PlanEvent(name: "Silent Disco at Fort Mason", location: "Fort Mason", time: "8:00 PM", day: 22, month: "Mar", attendees: 45, isInvite: false, isPast: false)
        ]
        
        invites = [
            PlanEvent(name: "Masquerade Ball", location: "Historic Mansion", time: "9:00 PM", day: 5, month: "Apr", attendees: 32, isInvite: true, isPast: false),
            PlanEvent(name: "Murder Mystery Yacht", location: "SF Bay", time: "6:00 PM", day: 12, month: "Apr", attendees: 18, isInvite: true, isPast: false)
        ]
        
        pastEvents = [
            PlanEvent(name: "New Year's Eve Gala", location: "City Hall", time: "10:00 PM", day: 31, month: "Dec", attendees: 120, isInvite: false, isPast: true),
            PlanEvent(name: "Valentine's Day Dinner", location: "Presidio", time: "7:30 PM", day: 14, month: "Feb", attendees: 24, isInvite: false, isPast: true)
        ]
    }
}

// MARK: - Preview

#Preview {
    EnhancedPlansView()
}
