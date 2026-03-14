import SwiftUI

// MARK: - ViviChatView

/// Vivi AI Chat Interface
/// Conversational onboarding + ongoing recommendations
struct ViviChatView: View {
    @StateObject private var viewModel = ViviChatViewModel()
    @State private var messageText = ""
    @FocusState private var isInputFocused: Bool

    var body: some View {
        ZStack {
            VennColors.darkBg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                ChatHeader()

                // Messages area
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 14) {
                            ForEach(viewModel.messages) { message in
                                MessageBubble(message: message)
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
                    onSend: {
                        let text = messageText
                        messageText = ""
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
        HStack(spacing: 12) {
            // Vivi avatar — solid coral circle with "V"
            ZStack {
                Circle()
                    .fill(VennColors.coral)
                    .frame(width: 34, height: 34)

                Text("V")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 5) {
                    Text("Vivi")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(VennColors.textPrimary)

                    Circle()
                        .fill(VennColors.success)
                        .frame(width: 6, height: 6)
                }

                Text("AI concierge")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(VennColors.textTertiary)
            }

            Spacer()
        }
        .padding(.horizontal, VennSpacing.xl)
        .padding(.vertical, 14)
        .background(
            VennColors.surfacePrimary
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(VennColors.borderSubtle)
                        .frame(height: 1)
                }
        )
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            if message.isFromUser { Spacer(minLength: 56) }

            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 6) {
                if message.isFromUser {
                    userBubble
                } else {
                    viviBubble
                }

                Text(message.timestamp, style: .time)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(VennColors.textTertiary)
            }

            if !message.isFromUser { Spacer(minLength: 56) }
        }
        .transition(
            .asymmetric(
                insertion: .scale(scale: 0.85, anchor: message.isFromUser ? .bottomTrailing : .bottomLeading)
                    .combined(with: .opacity),
                removal: .opacity
            )
        )
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: message.id)
    }

    private var userBubble: some View {
        Text(message.text)
            .font(.system(size: 16))
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
            .font(.system(size: 16))
            .foregroundColor(VennColors.textPrimary)
            .padding(.horizontal, VennSpacing.lg)
            .padding(.vertical, VennSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(VennColors.surfaceSecondary)
            )
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
                        .fill(VennColors.textSecondary)
                        .frame(width: 7, height: 7)
                        .scaleEffect(phase == index ? 1.3 : 0.85)
                        .opacity(phase == index ? 1.0 : 0.45)
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
            .font(.system(size: 16))
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
