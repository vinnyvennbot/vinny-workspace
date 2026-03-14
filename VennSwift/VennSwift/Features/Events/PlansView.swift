import SwiftUI

// MARK: - Plan Model

struct UserPlan: Identifiable {
    let id: String
    let title: String
    let dateFormatted: String
    let location: String
    let attendeeCount: Int
    let isHost: Bool
    let isPast: Bool
    let accentColor: Color
}

private let mockPlans: [UserPlan] = [
    UserPlan(id: "1", title: "Venn Club Dinner",       dateFormatted: "Fri, Feb 28 · 7:00 PM",  location: "The Barrel Room, SF",  attendeeCount: 17, isHost: false, isPast: false, accentColor: Color(red: 255/255, green: 127/255, blue: 110/255)),
    UserPlan(id: "2", title: "80s/90s Nostalgia Night", dateFormatted: "Sat, Mar 15 · 9:00 PM", location: "TBD",                   attendeeCount: 29, isHost: false, isPast: false, accentColor: Color(red: 180/255, green: 130/255, blue: 255/255)),
    UserPlan(id: "3", title: "Rooftop Wine Night",      dateFormatted: "Fri, Jan 17 · 6:30 PM",  location: "Foreign Cinema, SF",   attendeeCount: 12, isHost: true,  isPast: true,  accentColor: Color(red: 255/255, green: 185/255, blue: 106/255)),
    UserPlan(id: "4", title: "Silent Disco",            dateFormatted: "Sat, Jan 4 · 8:00 PM",   location: "Fort Mason, SF",       attendeeCount: 45, isHost: false, isPast: true,  accentColor: Color(red: 100/255, green: 190/255, blue: 240/255))
]

// MARK: - PlansView

struct PlansView: View {
    private var upcoming: [UserPlan] { mockPlans.filter { !$0.isPast } }
    private var past: [UserPlan]     { mockPlans.filter { $0.isPast  } }

    var body: some View {
        ZStack {
            VennColors.darkBg.ignoresSafeArea()

            VStack(spacing: 0) {
                plansHeader

                if mockPlans.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 28) {
                            if !upcoming.isEmpty {
                                planSection(title: "Upcoming", plans: upcoming)
                            }
                            if !past.isEmpty {
                                planSection(title: "Past", plans: past, dimmed: true)
                            }
                        }
                        .padding(.top, VennSpacing.xl)
                        .padding(.horizontal, VennSpacing.xl)
                        .padding(.bottom, VennSpacing.huge)
                    }
                }
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
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(VennColors.textSecondary)
            }

            Spacer()

            Button {
                // TODO: Create new plan
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(VennColors.coral)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(VennColors.surfaceSecondary)
                    )
            }
        }
        .padding(.horizontal, VennSpacing.xl)
        .padding(.top, VennSpacing.xl)
        .padding(.bottom, VennSpacing.sm)
    }

    // MARK: - Section

    private func planSection(title: String, plans: [UserPlan], dimmed: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: VennSpacing.md) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .tracking(0.8)
                .foregroundColor(VennColors.textTertiary)
                .textCase(.uppercase)

            ForEach(plans) { plan in
                PlanCard(plan: plan, dimmed: dimmed)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: VennSpacing.xl) {
            Spacer()

            ZStack {
                Circle()
                    .fill(VennColors.coralSubtle)
                    .frame(width: 100, height: 100)
                Image(systemName: "calendar.badge.exclamationmark")
                    .font(.system(size: 40))
                    .foregroundColor(VennColors.coral.opacity(0.5))
            }

            VStack(spacing: VennSpacing.sm) {
                Text("No plans yet")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(VennColors.textPrimary)

                Text("RSVP to events or create your own\nto see them here")
                    .font(.system(size: 15))
                    .foregroundColor(VennColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding(.horizontal, VennSpacing.xxxl)
    }
}

// MARK: - PlanCard

struct PlanCard: View {
    let plan: UserPlan
    var dimmed: Bool = false

    var body: some View {
        HStack(spacing: VennSpacing.lg) {
            // Left accent bar
            RoundedRectangle(cornerRadius: 3)
                .fill(dimmed ? plan.accentColor.opacity(0.35) : plan.accentColor)
                .frame(width: 3, height: 60)

            VStack(alignment: .leading, spacing: 6) {
                // Title + host pill
                HStack(spacing: VennSpacing.sm) {
                    Text(plan.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(VennColors.textPrimary)
                        .lineLimit(1)

                    if plan.isHost {
                        Text("Host")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(0.5)
                            .foregroundColor(VennColors.coral)
                            .padding(.horizontal, VennSpacing.sm)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(VennColors.coralSubtle)
                            )
                    }
                }

                // Date
                Label(plan.dateFormatted, systemImage: "calendar")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(VennColors.textSecondary)

                // Location + attendee count
                HStack(spacing: VennSpacing.md) {
                    Label(plan.location, systemImage: "mappin")
                        .font(.system(size: 12))
                        .foregroundColor(VennColors.textTertiary)
                        .lineLimit(1)

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 11))
                        Text("\(plan.attendeeCount)")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(VennColors.coral)
                }
            }
        }
        .padding(VennSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(VennColors.surfacePrimary)
        )
        .opacity(dimmed ? 0.5 : 1.0)
    }
}

// MARK: - Preview

#Preview {
    PlansView()
}
