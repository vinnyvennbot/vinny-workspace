import SwiftUI

// MARK: - ViviChatView

/// Vivi AI Chat Interface
/// Conversational onboarding + ongoing recommendations
struct ViviChatView: View {
    @StateObject private var viewModel = ViviChatViewModel()
    @State private var messageText = ""
    @FocusState private var isInputFocused: Bool
    @State private var sendBounce = false

    var body: some View {
        ZStack {
            // Subtle gradient background — darkBg at top, slightly lighter at bottom
            LinearGradient(
                colors: [VennColors.darkBg, VennColors.surfacePrimary],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                ChatHeader()

                // Messages area
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 14) {
                            ForEach(Array(viewModel.messages.enumerated()), id: \.element.id) { index, message in
                                MessageBubble(message: message, index: index, onQuickReply: { replyText in
                                    viewModel.sendMessage(replyText)
                                })
                                .id(message.id)
                            }

                            if viewModel.isTyping {
                                TypingIndicator()
                                    .id("typing")
                            }

                            // Bottom anchor
                            Color.clear
                                .frame(height: 8)
                                .id("bottom")
                        }
                        .padding(.horizontal, VennSpacing.lg)
                        .padding(.top, VennSpacing.lg)
                        .padding(.bottom, VennSpacing.sm)
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        withAnimation(.spring(response: 0.3)) {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                    .onChange(of: viewModel.isTyping) { _ in
                        withAnimation(.spring(response: 0.3)) {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                }

                // Input bar
                ChatInput(
                    text: $messageText,
                    isFocused: $isInputFocused,
                    sendBounce: $sendBounce,
                    onSend: {
                        let text = messageText
                        messageText = ""
                        sendBounce.toggle()
                        viewModel.sendMessage(text)
                    }
                )
            }
        }
        .onAppear {
            viewModel.sendWelcomeMessage()
        }
    }
}

// MARK: - Chat Header

struct ChatHeader: View {
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(VennColors.coral)
                .frame(width: 26, height: 26)
                .overlay(
                    Text("V")
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                )
                .pulse(from: 0.95, to: 1.05, duration: 2.0)

            Text("Vivi")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(VennColors.textPrimary)

            Circle()
                .fill(VennColors.success)
                .frame(width: 5, height: 5)

            Spacer()

            Text("AI concierge")
                .font(VennTypography.caption)
                .foregroundColor(VennColors.textTertiary)
        }
        .padding(.horizontal, VennSpacing.xl)
        .padding(.vertical, 10)
        .background(
            VennColors.darkBg
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(VennColors.borderSubtle)
                        .frame(height: 0.5)
                }
        )
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: ChatMessage
    let index: Int

    @State private var appeared = false

    private let quickReplies = ["Tell me more", "What's next?", "Show events"]
    var onQuickReply: ((String) -> Void)?

    var body: some View {
        VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: VennSpacing.sm) {
            HStack(alignment: .bottom, spacing: 0) {
                if message.isFromUser { Spacer(minLength: 56) }

                VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 6) {
                    if message.isFromUser {
                        userBubble
                    } else {
                        viviBubble
                    }

                    HStack(spacing: VennSpacing.xs) {
                        Text(message.timestamp, style: .time)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(VennColors.textTertiary)

                        if message.isFromUser {
                            Text("Delivered")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(VennColors.textTertiary)
                        }
                    }
                }

                if !message.isFromUser { Spacer(minLength: 56) }
            }

            // Quick reply chips — only shown below Vivi messages
            if !message.isFromUser {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: VennSpacing.sm) {
                        ForEach(quickReplies, id: \.self) { reply in
                            QuickReplyChip(text: reply, onTap: {
                                onQuickReply?(reply)
                            })
                        }
                    }
                    .padding(.horizontal, VennSpacing.xs)
                }
                .opacity(appeared ? 1.0 : 0.0)
                .offset(y: appeared ? 0 : 6)
            }
        }
        .opacity(appeared ? 1.0 : 0.0)
        .offset(
            x: appeared ? 0 : (message.isFromUser ? 24 : -24),
            y: appeared ? 0 : 12
        )
        .animation(
            .spring(response: 0.42, dampingFraction: 0.78)
                .delay(Double(index % 5) * 0.06),
            value: appeared
        )
        .onAppear {
            appeared = true
        }
    }

    private var userBubble: some View {
        Text(message.text)
            .font(VennTypography.bodyLarge)
            .foregroundColor(.white)
            .padding(.horizontal, VennSpacing.lg)
            .padding(.vertical, VennSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(VennColors.coral)
                    .shadow(color: VennColors.coral.opacity(0.2), radius: 8, y: 3)
            )
    }

    private var viviBubble: some View {
        Text(message.text)
            .font(VennTypography.bodyLarge)
            .foregroundColor(VennColors.textPrimary)
            .padding(.horizontal, VennSpacing.lg)
            .padding(.vertical, VennSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(VennColors.surfaceSecondary)
            )
    }
}

// MARK: - Quick Reply Chip

struct QuickReplyChip: View {
    let text: String
    var onTap: (() -> Void)? = nil
    @State private var isPressed = false

    var body: some View {
        Text(text)
            .font(VennTypography.captionBold)
            .foregroundColor(VennColors.textSecondary)
            .padding(.horizontal, VennSpacing.md)
            .padding(.vertical, VennSpacing.xs + 2)
            .background(
                Capsule(style: .continuous)
                    .fill(VennColors.surfaceTertiary)
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(VennColors.borderMedium, lineWidth: 1)
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(VennAnimation.micro, value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
            .onTapGesture {
                HapticManager.shared.selectionFeedback()
                onTap?()
            }
    }
}

// MARK: - Typing Indicator

struct TypingIndicator: View {
    @State private var phase: Int = 0

    var body: some View {
        HStack {
            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(VennColors.coral)
                        .frame(width: 7, height: 7)
                        .scaleEffect(phase == index ? 1.3 : 0.85)
                        .opacity(phase == index ? 1.0 : 0.35)
                        .animation(
                            .easeInOut(duration: 0.5)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.18),
                            value: phase
                        )
                }
            }
            .padding(.horizontal, VennSpacing.lg)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(VennColors.surfaceSecondary)
            )

            Spacer()
        }
        .onAppear { phase = 1 }
    }
}

// MARK: - Chat Input

struct ChatInput: View {
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding
    @Binding var sendBounce: Bool
    let onSend: () -> Void

    private var hasContent: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        HStack(spacing: VennSpacing.md) {
            // Text field
            TextField("", text: $text, prompt:
                Text("Message Vivi...").foregroundColor(VennColors.textTertiary)
            )
            .font(VennTypography.bodyLarge)
            .foregroundColor(VennColors.textPrimary)
            .padding(.horizontal, VennSpacing.lg)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(VennColors.surfaceSecondary)
            )
            .focused(isFocused)
            .onSubmit {
                guard hasContent else { return }
                onSend()
            }

            // Send button
            Button(action: {
                guard hasContent else { return }
                onSend()
            }) {
                ZStack {
                    Circle()
                        .fill(
                            hasContent
                                ? AnyShapeStyle(VennGradients.primary)
                                : AnyShapeStyle(VennColors.surfaceSecondary)
                        )
                        .frame(width: 40, height: 40)
                        .shadow(
                            color: hasContent ? VennColors.coral.opacity(0.25) : .clear,
                            radius: 8,
                            y: 3
                        )

                    Image(systemName: "arrow.up")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(hasContent ? .white : VennColors.textTertiary)
                }
            }
            .disabled(!hasContent)
            .bounce(trigger: sendBounce)
            .animation(VennAnimation.snappy, value: hasContent)
        }
        .padding(.horizontal, VennSpacing.lg)
        .padding(.vertical, VennSpacing.md)
        .background(
            VennColors.surfacePrimary
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(VennColors.borderSubtle)
                        .frame(height: 1)
                }
        )
    }
}

// MARK: - Preview

#Preview {
    ViviChatView()
}
