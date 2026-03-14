import SwiftUI

// MARK: - Plan Model

struct UserPlan: Identifiable {
    let id: String
    let title: String
    let dateFormatted: String
    /// Raw date used for countdown calculation. nil for past events.
    let eventDate: Date?
    let location: String
    let attendeeCount: Int
    let isHost: Bool
    let isPast: Bool
    let accentColor: Color
}

// MARK: - Countdown Helper

private func daysUntil(_ date: Date?) -> Int? {
    guard let date = date else { return nil }
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let target = calendar.startOfDay(for: date)
    let components = calendar.dateComponents([.day], from: today, to: target)
    guard let days = components.day, days >= 0 else { return nil }
    return days
}

private let mockPlans: [UserPlan] = [
    UserPlan(
        id: "1",
        title: "Venn Club Dinner",
        dateFormatted: "Fri, Feb 28 · 7:00 PM",
        eventDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()),
        location: "The Barrel Room, SF",
        attendeeCount: 17,
        isHost: false,
        isPast: false,
        accentColor: Color(red: 255/255, green: 127/255, blue: 110/255)
    ),
    UserPlan(
        id: "2",
        title: "80s/90s Nostalgia Night",
        dateFormatted: "Sat, Mar 15 · 9:00 PM",
        eventDate: Calendar.current.date(byAdding: .day, value: 14, to: Date()),
        location: "TBD",
        attendeeCount: 29,
        isHost: false,
        isPast: false,
        accentColor: Color(red: 180/255, green: 130/255, blue: 255/255)
    ),
    UserPlan(
        id: "3",
        title: "Rooftop Wine Night",
        dateFormatted: "Fri, Jan 17 · 6:30 PM",
        eventDate: nil,
        location: "Foreign Cinema, SF",
        attendeeCount: 12,
        isHost: true,
        isPast: true,
        accentColor: Color(red: 255/255, green: 185/255, blue: 106/255)
    ),
    UserPlan(
        id: "4",
        title: "Silent Disco",
        dateFormatted: "Sat, Jan 4 · 8:00 PM",
        eventDate: nil,
        location: "Fort Mason, SF",
        attendeeCount: 45,
        isHost: false,
        isPast: true,
        accentColor: Color(red: 100/255, green: 190/255, blue: 240/255)
    )
]

// MARK: - Segment

private enum PlanSegment: String, CaseIterable {
    case upcoming = "Upcoming"
    case past     = "Past"
}

// MARK: - PlansView

struct PlansView: View {
    @State private var selectedSegment: PlanSegment = .upcoming
    @State private var listAppeared = false
    @State private var showingCreatePlan = false

    private var upcoming: [UserPlan] { mockPlans.filter { !$0.isPast } }
    private var past: [UserPlan]     { mockPlans.filter {  $0.isPast  } }

    private var visiblePlans: [UserPlan] {
        selectedSegment == .upcoming ? upcoming : past
    }

    var body: some View {
        ZStack {
            VennColors.darkBg.ignoresSafeArea()

            VStack(spacing: 0) {
                plansHeader

                segmentedControl
                    .padding(.horizontal, VennSpacing.xl)
                    .padding(.top, VennSpacing.md)
                    .padding(.bottom, VennSpacing.xs)

                if mockPlans.isEmpty {
                    emptyState
                } else if visiblePlans.isEmpty {
                    emptySegmentState
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: VennSpacing.md) {
                            ForEach(Array(visiblePlans.enumerated()), id: \.element.id) { index, plan in
                                PlanCard(plan: plan, dimmed: selectedSegment == .past)
                                    .opacity(listAppeared ? 1 : 0)
                                    .offset(y: listAppeared ? 0 : 20)
                                    .animation(
                                        VennAnimation.standard.delay(Double(index) * 0.07),
                                        value: listAppeared
                                    )
                            }
                        }
                        .padding(.top, VennSpacing.lg)
                        .padding(.horizontal, VennSpacing.xl)
                        .padding(.bottom, VennSpacing.huge)
                    }
                }
            }
        }
        .sheet(isPresented: $showingCreatePlan) {
            CreatePlanSheet()
        }
        .onAppear {
            withAnimation(VennAnimation.gentle) {
                listAppeared = true
            }
        }
        .onChange(of: selectedSegment) { _ in
            listAppeared = false
            withAnimation(VennAnimation.gentle) {
                listAppeared = true
            }
        }
    }

    // MARK: - Header

    private var plansHeader: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Plans")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(VennColors.textPrimary)

                Text("Events you're attending or hosting")
                    .font(VennTypography.buttonSmall)
                    .foregroundColor(VennColors.textSecondary)
            }

            Spacer()

            PlusCreateButton(onTap: {
                showingCreatePlan = true
            })
        }
        .padding(.horizontal, VennSpacing.xl)
        .padding(.top, VennSpacing.xl)
        .padding(.bottom, VennSpacing.sm)
    }

    // MARK: - Segmented Control

    private var segmentedControl: some View {
        HStack(spacing: 0) {
            ForEach(PlanSegment.allCases, id: \.self) { segment in
                Button {
                    Task { @MainActor in
                        HapticManager.shared.selectionFeedback()
                    }
                    withAnimation(VennAnimation.snappy) {
                        selectedSegment = segment
                    }
                } label: {
                    Text(segment.rawValue)
                        .font(VennTypography.captionBold)
                        .foregroundColor(selectedSegment == segment ? VennColors.textPrimary : VennColors.textTertiary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, VennSpacing.sm + 2)
                        .background(
                            Group {
                                if selectedSegment == segment {
                                    RoundedRectangle(cornerRadius: VennRadius.small, style: .continuous)
                                        .fill(VennColors.surfaceTertiary)
                                }
                            }
                        )
                }
            }
        }
        .padding(3)
        .background(
            RoundedRectangle(cornerRadius: VennRadius.medium, style: .continuous)
                .fill(VennColors.surfaceSecondary)
        )
    }

    // MARK: - Empty States

    private var emptyState: some View {
        emptyContent(
            icon: "calendar.badge.exclamationmark",
            title: "No plans yet",
            subtitle: "RSVP to events or create your own\nto see them here"
        )
    }

    private var emptySegmentState: some View {
        emptyContent(
            icon: selectedSegment == .upcoming ? "calendar.badge.clock" : "clock.arrow.circlepath",
            title: selectedSegment == .upcoming ? "Nothing coming up" : "No past events",
            subtitle: selectedSegment == .upcoming
                ? "RSVP to events to see them here"
                : "Attended events will appear here"
        )
    }

    private func emptyContent(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: VennSpacing.xl) {
            Spacer()

            ZStack {
                Circle()
                    .fill(VennColors.coralSubtle)
                    .frame(width: 100, height: 100)
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundColor(VennColors.coral.opacity(0.5))
            }

            VStack(spacing: VennSpacing.sm) {
                Text(title)
                    .font(VennTypography.subheading)
                    .foregroundColor(VennColors.textPrimary)

                Text(subtitle)
                    .font(VennTypography.body)
                    .foregroundColor(VennColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding(.horizontal, VennSpacing.xxxl)
    }
}

// MARK: - Plus Create Button

private struct PlusCreateButton: View {
    let onTap: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button {
            HapticManager.shared.impact(.light)
            onTap()
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(VennGradients.primary)
                        .shadow(
                            color: VennColors.coral.opacity(0.40),
                            radius: 10,
                            x: 0,
                            y: 4
                        )
                )
        }
        .pressScale(isPressed: $isPressed, scale: 0.92, haptic: nil)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Create Plan Sheet

private struct CreatePlanSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var planTitle = ""
    @State private var planLocation = ""
    @State private var planDate = Date().addingTimeInterval(7 * 24 * 3600)
    @State private var inviteFriends = false

    var body: some View {
        ZStack {
            VennColors.darkBg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(VennColors.textSecondary)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(VennColors.surfaceTertiary))
                    }

                    Spacer()

                    Text("Create Plan")
                        .font(VennTypography.subheading)
                        .foregroundColor(VennColors.textPrimary)

                    Spacer()

                    Color.clear.frame(width: 32, height: 32)
                }
                .padding(.horizontal, VennSpacing.xl)
                .padding(.top, VennSpacing.xl)
                .padding(.bottom, VennSpacing.lg)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: VennSpacing.lg) {
                        // Title field
                        VStack(alignment: .leading, spacing: VennSpacing.sm) {
                            Text("Plan Title")
                                .font(VennTypography.captionBold)
                                .foregroundColor(VennColors.textSecondary)

                            TextField("", text: $planTitle, prompt:
                                Text("e.g. Rooftop Dinner").foregroundColor(VennColors.textTertiary)
                            )
                            .font(VennTypography.bodyLarge)
                            .foregroundColor(VennColors.textPrimary)
                            .padding(.horizontal, VennSpacing.lg)
                            .padding(.vertical, VennSpacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: VennRadius.medium, style: .continuous)
                                    .fill(VennColors.surfacePrimary)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: VennRadius.medium, style: .continuous)
                                            .stroke(VennColors.borderMedium, lineWidth: 1)
                                    )
                            )
                        }

                        // Date picker
                        VStack(alignment: .leading, spacing: VennSpacing.sm) {
                            Text("Date & Time")
                                .font(VennTypography.captionBold)
                                .foregroundColor(VennColors.textSecondary)

                            DatePicker(
                                "",
                                selection: $planDate,
                                in: Date()...,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .colorScheme(.dark)
                            .padding(.horizontal, VennSpacing.lg)
                            .padding(.vertical, VennSpacing.md)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: VennRadius.medium, style: .continuous)
                                    .fill(VennColors.surfacePrimary)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: VennRadius.medium, style: .continuous)
                                            .stroke(VennColors.borderMedium, lineWidth: 1)
                                    )
                            )
                        }

                        // Location field
                        VStack(alignment: .leading, spacing: VennSpacing.sm) {
                            Text("Location")
                                .font(VennTypography.captionBold)
                                .foregroundColor(VennColors.textSecondary)

                            HStack(spacing: VennSpacing.sm) {
                                Image(systemName: "mappin")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(VennColors.coral)

                                TextField("", text: $planLocation, prompt:
                                    Text("Where is it?").foregroundColor(VennColors.textTertiary)
                                )
                                .font(VennTypography.bodyLarge)
                                .foregroundColor(VennColors.textPrimary)
                            }
                            .padding(.horizontal, VennSpacing.lg)
                            .padding(.vertical, VennSpacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: VennRadius.medium, style: .continuous)
                                    .fill(VennColors.surfacePrimary)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: VennRadius.medium, style: .continuous)
                                            .stroke(VennColors.borderMedium, lineWidth: 1)
                                    )
                            )
                        }

                        // Invite friends toggle
                        HStack(spacing: 14) {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 18))
                                .foregroundColor(VennColors.indigo)
                                .frame(width: 28)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Invite Friends")
                                    .font(VennTypography.bodyMedium)
                                    .foregroundColor(VennColors.textPrimary)
                                Text("Share plan with your connections")
                                    .font(VennTypography.caption)
                                    .foregroundColor(VennColors.textSecondary)
                            }

                            Spacer()

                            Toggle("", isOn: $inviteFriends)
                                .labelsHidden()
                                .tint(VennColors.coral)
                                .onChange(of: inviteFriends) { _ in
                                    HapticManager.shared.selectionFeedback()
                                }
                        }
                        .padding(VennSpacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: VennRadius.medium, style: .continuous)
                                .fill(VennColors.surfacePrimary)
                                .overlay(
                                    RoundedRectangle(cornerRadius: VennRadius.medium, style: .continuous)
                                        .stroke(VennColors.borderMedium, lineWidth: 1)
                                )
                        )

                        // Create button
                        Button {
                            HapticManager.shared.impact(.medium)
                            dismiss()
                        } label: {
                            Text("Create Plan")
                                .font(VennTypography.buttonLabel)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(
                                    Capsule()
                                        .fill(
                                            planTitle.isEmpty
                                                ? AnyShapeStyle(VennColors.surfaceTertiary)
                                                : AnyShapeStyle(VennGradients.primary)
                                        )
                                )
                        }
                        .disabled(planTitle.isEmpty)
                        .padding(.top, VennSpacing.md)
                    }
                    .padding(.horizontal, VennSpacing.xl)
                    .padding(.bottom, VennSpacing.huge)
                }
            }
        }
    }
}

// MARK: - PlanCard

struct PlanCard: View {
    let plan: UserPlan
    var dimmed: Bool = false

    @State private var isPressed = false
    @State private var barAppeared = false
    @State private var showingDetail = false

    private var countdownDays: Int? { daysUntil(plan.eventDate) }

    // Convert UserPlan to DiscoverEvent for the detail sheet
    private var asDiscoverEvent: DiscoverEvent {
        DiscoverEvent(
            id: plan.id,
            name: plan.title,
            dateFormatted: plan.dateFormatted,
            locationShort: plan.location,
            imageUrl: nil,
            attendees: plan.attendeeCount,
            isFeatured: false
        )
    }

    var body: some View {
        HStack(spacing: VennSpacing.lg) {
            // Left accent bar — slides in from the left on appear
            RoundedRectangle(cornerRadius: 3)
                .fill(dimmed ? plan.accentColor.opacity(0.35) : plan.accentColor)
                .frame(width: barAppeared ? 3 : 0, height: 60)
                .animation(VennAnimation.standard.delay(0.1), value: barAppeared)
                .clipped()

            VStack(alignment: .leading, spacing: 6) {
                // Title row: title + host pill + countdown badge
                HStack(spacing: VennSpacing.sm) {
                    Text(plan.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(dimmed ? VennColors.textSecondary : VennColors.textPrimary)
                        .lineLimit(1)
                        .strikethrough(dimmed, color: VennColors.textTertiary)

                    if plan.isHost {
                        Text("Host")
                            .font(VennTypography.pill)
                            .tracking(0.5)
                            .foregroundColor(VennColors.coral)
                            .padding(.horizontal, VennSpacing.sm)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(VennColors.coralSubtle)
                            )
                            .shadow(
                                color: VennColors.coral.opacity(0.25),
                                radius: 6,
                                x: 0,
                                y: 2
                            )
                    }

                    Spacer()

                    if !dimmed, let days = countdownDays {
                        countdownBadge(days: days)
                    }

                    if dimmed {
                        Text("Past")
                            .font(VennTypography.captionBold)
                            .foregroundColor(VennColors.textTertiary)
                            .padding(.horizontal, VennSpacing.sm)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(VennColors.surfaceTertiary)
                            )
                    }
                }

                // Date
                Label(plan.dateFormatted, systemImage: "calendar")
                    .font(VennTypography.captionBold)
                    .foregroundColor(dimmed ? VennColors.textTertiary : VennColors.textSecondary)

                // Location + attendee count
                HStack(spacing: VennSpacing.md) {
                    Label(plan.location, systemImage: "mappin")
                        .font(VennTypography.caption)
                        .foregroundColor(VennColors.textTertiary)
                        .lineLimit(1)

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 11))
                        Text("\(plan.attendeeCount)")
                            .font(VennTypography.captionBold)
                    }
                    .foregroundColor(dimmed ? VennColors.textTertiary : VennColors.coral)
                }
            }
        }
        .padding(VennSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: VennRadius.large, style: .continuous)
                .fill(VennColors.surfacePrimary)
        )
        .opacity(dimmed ? 0.55 : 1.0)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .contentShape(Rectangle())
        .onTapGesture {
            HapticManager.shared.impact(.light)
            showingDetail = true
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .onAppear {
            withAnimation(VennAnimation.standard) {
                barAppeared = true
            }
        }
        .onDisappear {
            barAppeared = false
        }
        .sheet(isPresented: $showingDetail) {
            EventDetailView(event: asDiscoverEvent)
        }
    }

    // MARK: - Countdown Badge

    @ViewBuilder
    private func countdownBadge(days: Int) -> some View {
        let label: String = {
            switch days {
            case 0:  return "Today"
            case 1:  return "Tomorrow"
            default: return "In \(days) days"
            }
        }()

        Text(label)
            .font(VennTypography.captionBold)
            .foregroundColor(.white)
            .padding(.horizontal, VennSpacing.sm)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(VennColors.coral)
                    .shadow(
                        color: VennColors.coral.opacity(0.40),
                        radius: 6,
                        x: 0,
                        y: 2
                    )
            )
    }
}

// MARK: - Preview

#Preview {
    PlansView()
}
