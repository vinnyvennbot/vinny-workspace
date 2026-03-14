import SwiftUI

/// Enhanced Vivi Chat View - Premium chat experience
/// Features: Advanced animations, haptics, message reactions, voice input
struct EnhancedViviChatView: View {
    @StateObject private var viewModel = ViviChatViewModel()
    @State private var messageText = ""
    @State private var scrollOffset: CGFloat = 0
    @State private var scrollVelocity: CGFloat = 0
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        ZStack {
            // Background with subtle gradient
            LinearGradient(
                colors: [
                    VennColors.darkBg,
                    VennColors.darkBg.opacity(0.95)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Enhanced header with parallax
                EnhancedChatHeader()
                    .parallax(speed: 0.5, scrollOffset: $scrollOffset)
                
                // Messages area
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 16) {
                            ForEach(Array(viewModel.messages.enumerated()), id: \.element.id) { index, message in
                                EnhancedMessageBubble(message: message, index: index)
                                    .id(message.id)
                                    .scrollScale(
                                        from: 0.95,
                                        to: 1.0,
                                        threshold: 300,
                                        scrollOffset: $scrollOffset
                                    )
                            }
                            
                            if viewModel.isTyping {
                                EnhancedTypingIndicator()
                                    .id("typing")
                            }
                            
                            // Bottom anchor
                            Color.clear
                                .frame(height: 8)
                                .id("bottom")
                        }
                        .padding(.horizontal, VennSpacing.lg)
                        .padding(.top, VennSpacing.xl)
                        .padding(.bottom, VennSpacing.sm)
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
                    .onChange(of: viewModel.messages.count) { _ in
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                    .onChange(of: viewModel.isTyping) { _ in
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                }
                
                // Enhanced input bar
                EnhancedChatInput(
                    text: $messageText,
                    isFocused: $isInputFocused,
                    onSend: {
                        sendMessage()
                    }
                )
            }
        }
        .onAppear {
            viewModel.sendWelcomeMessage()
        }
        .withToasts()
    }
    
    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        messageText = ""
        
        // Haptic feedback
        HapticManager.shared.impact(.medium)
        
        // Send message
        viewModel.sendMessage(text)
    }
}

// MARK: - Enhanced Chat Header

struct EnhancedChatHeader: View {
    @State private var isOnline = true
    @State private var pulsePhase: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 14) {
            // Vivi avatar with glow
            ZStack {
                // Glow effect
                Circle()
                    .fill(VennColors.coral.opacity(0.3))
                    .frame(width: 46, height: 46)
                    .blur(radius: 8)
                    .scaleEffect(1 + pulsePhase * 0.2)
                
                // Main avatar
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                VennColors.coral,
                                VennColors.gold
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text("V")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    )
                    .shadow(color: VennColors.coral.opacity(0.3), radius: 8, y: 2)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    pulsePhase = 1
                }
            }
            
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text("Vivi")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(VennColors.textPrimary)
                    
                    // Online indicator
                    HStack(spacing: 4) {
                        Circle()
                            .fill(VennColors.success)
                            .frame(width: 7, height: 7)
                            .pulse(from: 1.0, to: 1.3, duration: 1.5)
                        
                        Text("Online")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(VennColors.success)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(VennColors.success.opacity(0.1))
                    )
                }
                
                Text("Your AI event concierge")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(VennColors.textSecondary)
            }
            
            Spacer()
            
            // Info button
            Button {
                HapticManager.shared.impact(.light)
                ToastManager.shared.showInfo("Vivi is powered by Claude Sonnet 4")
            } label: {
                Image(systemName: "info.circle")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(VennColors.textTertiary)
            }
        }
        .padding(.horizontal, VennSpacing.xl)
        .padding(.vertical, 16)
        .background(
            VennColors.surfacePrimary
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    VennColors.coral.opacity(0.1),
                                    VennColors.gold.opacity(0.05)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 1)
                }
        )
    }
}

// MARK: - Enhanced Message Bubble

struct EnhancedMessageBubble: View {
    let message: ChatMessage
    let index: Int
    
    @State private var appeared = false
    @State private var isPressed = false
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            if message.isFromUser { Spacer(minLength: 60) }
            
            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 8) {
                // Message bubble
                Group {
                    if message.isFromUser {
                        userBubble
                    } else {
                        viviBubble
                    }
                }
                .pressScale(isPressed: $isPressed, scale: 0.97, haptic: nil)
                .onTapGesture {
                    isPressed.toggle()
                }
                
                // Timestamp
                Text(message.timestamp, style: .time)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(VennColors.textTertiary)
            }
            
            if !message.isFromUser { Spacer(minLength: 60) }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75).delay(Double(index) * 0.05)) {
                appeared = true
            }
        }
    }
    
    private var userBubble: some View {
        Text(message.text)
            .font(.system(size: 16, weight: .regular, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                VennColors.coral,
                                VennColors.coral.opacity(0.9)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: VennColors.coral.opacity(0.3), radius: 12, y: 4)
            )
    }
    
    private var viviBubble: some View {
        Text(message.text)
            .font(.system(size: 16, weight: .regular, design: .rounded))
            .foregroundColor(VennColors.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 8, y: 2)
            )
    }
}

// MARK: - Enhanced Typing Indicator

struct EnhancedTypingIndicator: View {
    @State private var phase: Int = 0
    @State private var appeared = false
    
    var body: some View {
        HStack {
            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(VennColors.coral)
                        .frame(width: 9, height: 9)
                        .scaleEffect(phase == index ? 1.3 : 0.9)
                        .opacity(phase == index ? 1.0 : 0.5)
                        .shadow(color: VennColors.coral.opacity(0.3), radius: 4)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(VennColors.coral.opacity(0.2), lineWidth: 1)
                    )
            )
            
            Spacer()
        }
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.8)
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                appeared = true
            }
            
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.3)) {
                    phase = (phase + 1) % 3
                }
            }
        }
    }
}

// MARK: - Enhanced Chat Input

struct EnhancedChatInput: View {
    @Binding var text: String
    @FocusState.Binding var isFocused: Bool
    let onSend: () -> Void
    
    @State private var inputHeight: CGFloat = 40
    @State private var isRecording = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Voice input button
            Button {
                HapticManager.shared.impact(.medium)
                isRecording.toggle()
                
                if isRecording {
                    ToastManager.shared.showInfo("Voice input coming soon!")
                }
            } label: {
                Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                    .font(.system(size: 26, weight: .medium))
                    .foregroundColor(isRecording ? .red : VennColors.textTertiary)
                    .pulse(from: 1.0, to: 1.2, duration: 0.8)
            }
            .opacity(text.isEmpty ? 1 : 0)
            .disabled(!text.isEmpty)
            
            // Text input
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text("Message Vivi...")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(VennColors.textTertiary)
                        .padding(.horizontal, 16)
                }
                
                TextField("", text: $text, axis: .vertical)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(VennColors.textPrimary)
                    .focused($isFocused)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .lineLimit(1...5)
                    .submitLabel(.send)
                    .onSubmit {
                        if !text.isEmpty {
                            onSend()
                        }
                    }
            }
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(isFocused ? VennColors.coral.opacity(0.3) : Color.white.opacity(0.1), lineWidth: 1.5)
                    )
            )
            
            // Send button
            Button {
                onSend()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                VennColors.coral,
                                VennColors.gold
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: VennColors.coral.opacity(0.3), radius: 8, y: 2)
            }
            .disabled(text.isEmpty)
            .opacity(text.isEmpty ? 0.5 : 1.0)
            .scaleEffect(text.isEmpty ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: text.isEmpty)
        }
        .padding(.horizontal, VennSpacing.lg)
        .padding(.vertical, 12)
        .background(
            VennColors.surfacePrimary
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(Color.white.opacity(0.05))
                        .frame(height: 1)
                }
        )
    }
}

// MARK: - Preview

#Preview {
    EnhancedViviChatView()
}
