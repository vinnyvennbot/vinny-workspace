import SwiftUI

/// Swipeable Event Card - Tinder-style swipe interactions
/// Swipe right to save, left to skip, up for details
struct SwipeableEventCard: View {
    let event: DiscoverEvent
    let onSave: () -> Void
    let onSkip: () -> Void
    let onDetail: () -> Void
    
    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var overlayOpacity: Double = 0
    @State private var overlayType: OverlayType = .none
    @GestureState private var isDragging = false
    
    private enum OverlayType {
        case none, save, skip
    }
    
    // Swipe thresholds
    private let swipeThreshold: CGFloat = 100
    private let rotationAmount: Double = 20
    
    var body: some View {
        ZStack {
            // Base card
            EventCardView(event: event)
                .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
            
            // Overlay indicators
            overlayIndicator
        }
        .scaleEffect(scale)
        .rotationEffect(.degrees(rotation))
        .offset(offset)
        .gesture(dragGesture)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: offset)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: rotation)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: scale)
    }
    
    // MARK: - Overlay Indicator
    
    @ViewBuilder
    private var overlayIndicator: some View {
        if overlayType != .none {
            ZStack {
                // Background overlay
                Rectangle()
                    .fill(
                        overlayType == .save
                            ? Color.green.opacity(0.3)
                            : Color.red.opacity(0.3)
                    )
                    .cornerRadius(24)
                
                // Icon
                Image(systemName: overlayType == .save ? "heart.fill" : "xmark")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(overlayType == .save ? .green : .red)
                    .scaleEffect(overlayType == .save ? 1.2 : 1.0)
            }
            .opacity(overlayOpacity)
        }
    }
    
    // MARK: - Drag Gesture
    
    private var dragGesture: some Gesture {
        DragGesture()
            .updating($isDragging) { _, state, _ in
                state = true
            }
            .onChanged { value in
                handleDragChanged(value)
            }
            .onEnded { value in
                handleDragEnded(value)
            }
    }
    
    private func handleDragChanged(_ value: DragGesture.Value) {
        offset = value.translation
        
        // Rotation based on horizontal drag
        rotation = Double(value.translation.width / 20)
        
        // Scale down slightly while dragging
        scale = 0.95
        
        // Update overlay
        if value.translation.width > 50 {
            overlayType = .save
            overlayOpacity = min(Double(value.translation.width / swipeThreshold), 0.7)
            
            if value.translation.width > swipeThreshold / 2 {
                HapticManager.shared.impact(.light)
            }
        } else if value.translation.width < -50 {
            overlayType = .skip
            overlayOpacity = min(Double(-value.translation.width / swipeThreshold), 0.7)
            
            if value.translation.width < -swipeThreshold / 2 {
                HapticManager.shared.impact(.light)
            }
        } else {
            overlayType = .none
            overlayOpacity = 0
        }
        
        // Upward swipe for details
        if value.translation.height < -80 {
            HapticManager.shared.impact(.medium)
        }
    }
    
    private func handleDragEnded(_ value: DragGesture.Value) {
        // Determine action based on final position
        if value.translation.width > swipeThreshold {
            // Swipe right - Save
            animateSwipeOff(to: .save)
        } else if value.translation.width < -swipeThreshold {
            // Swipe left - Skip
            animateSwipeOff(to: .skip)
        } else if value.translation.height < -100 {
            // Swipe up - Details
            animateToDetail()
        } else {
            // Return to center
            resetPosition()
        }
    }
    
    // MARK: - Animations
    
    private func animateSwipeOff(to type: OverlayType) {
        let direction: CGFloat = type == .save ? 1 : -1
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            offset = CGSize(width: direction * 500, height: 0)
            rotation = Double(direction * 30)
            scale = 0.8
            overlayOpacity = 0
        }
        
        HapticManager.shared.impact(.medium)
        
        // Trigger callback after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if type == .save {
                onSave()
            } else {
                onSkip()
            }
            resetPosition()
        }
    }
    
    private func animateToDetail() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            scale = 1.05
        }
        
        HapticManager.shared.impact(.heavy)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            onDetail()
            resetPosition()
        }
    }
    
    private func resetPosition() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            offset = .zero
            rotation = 0
            scale = 1.0
            overlayOpacity = 0
            overlayType = .none
        }
    }
}

/// Swipeable Event Stack - Tinder-style card stack
struct SwipeableEventStack: View {
    @State private var events: [DiscoverEvent]
    let onSave: (DiscoverEvent) -> Void
    let onSkip: (DiscoverEvent) -> Void
    let onDetail: (DiscoverEvent) -> Void
    
    init(
        events: [DiscoverEvent],
        onSave: @escaping (DiscoverEvent) -> Void = { _ in },
        onSkip: @escaping (DiscoverEvent) -> Void = { _ in },
        onDetail: @escaping (DiscoverEvent) -> Void = { _ in }
    ) {
        _events = State(initialValue: events)
        self.onSave = onSave
        self.onSkip = onSkip
        self.onDetail = onDetail
    }
    
    var body: some View {
        ZStack {
            // Background cards (stacked effect)
            ForEach(Array(events.prefix(3).enumerated()), id: \.element.id) { index, event in
                if index > 0 {
                    EventCardView(event: event)
                        .scaleEffect(1 - CGFloat(index) * 0.05)
                        .offset(y: CGFloat(index) * 10)
                        .opacity(1 - Double(index) * 0.2)
                        .zIndex(Double(events.count - index))
                }
            }
            
            // Top card (swipeable)
            if let topEvent = events.first {
                SwipeableEventCard(
                    event: topEvent,
                    onSave: {
                        handleAction(topEvent, action: .save)
                    },
                    onSkip: {
                        handleAction(topEvent, action: .skip)
                    },
                    onDetail: {
                        handleAction(topEvent, action: .detail)
                    }
                )
                .zIndex(Double(events.count))
            }
        }
        .frame(height: 320)
    }
    
    private enum Action {
        case save, skip, detail
    }
    
    private func handleAction(_ event: DiscoverEvent, action: Action) {
        // Remove top card
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            events.removeFirst()
        }
        
        // Trigger callback
        switch action {
        case .save:
            onSave(event)
        case .skip:
            onSkip(event)
        case .detail:
            onDetail(event)
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        VennColors.darkBg.ignoresSafeArea()
        
        VStack(spacing: 40) {
            Text("Swipe Right to Save, Left to Skip, Up for Details")
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding()
            
            SwipeableEventStack(
                events: [
                    DiscoverEvent(id: "1", name: "Venn Club Dinner", dateFormatted: "Feb 28", locationShort: "The Barrel Room", imageUrl: nil, attendees: 17, isFeatured: true),
                    DiscoverEvent(id: "2", name: "80s/90s Nostalgia Night", dateFormatted: "Mar 15", locationShort: "TBD", imageUrl: nil, attendees: 29, isFeatured: true),
                    DiscoverEvent(id: "3", name: "Silent Disco", dateFormatted: "Tonight", locationShort: "Fort Mason", imageUrl: nil, attendees: 45, isFeatured: false)
                ],
                onSave: { event in
                    print("Saved: \(event.name)")
                },
                onSkip: { event in
                    print("Skipped: \(event.name)")
                },
                onDetail: { event in
                    print("Details: \(event.name)")
                }
            )
            .padding()
            
            // Action buttons
            HStack(spacing: 40) {
                Button {
                    HapticManager.shared.impact(.medium)
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.red)
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Circle()
                                        .stroke(Color.red, lineWidth: 2)
                                )
                        )
                }
                
                Button {
                    HapticManager.shared.impact(.heavy)
                } label: {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(VennColors.coral)
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Circle()
                                        .stroke(VennColors.coral, lineWidth: 2)
                                )
                        )
                }
                
                Button {
                    HapticManager.shared.impact(.medium)
                } label: {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.green)
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Circle()
                                        .stroke(Color.green, lineWidth: 2)
                                )
                        )
                }
            }
        }
    }
}
