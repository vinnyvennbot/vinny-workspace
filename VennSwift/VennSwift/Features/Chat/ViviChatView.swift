import SwiftUI

/// Vivi AI Chat Interface
/// Conversational onboarding + ongoing recommendations
struct ViviChatView: View {
    @StateObject private var viewModel = ViviChatViewModel()
    @State private var messageText = ""
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        ZStack {
            // Background - Deep warm black
            Color(red: 10/255, green: 8/255, blue: 6/255)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                ChatHeader()
                
                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                            
                            // Typing indicator
                            if viewModel.isTyping {
                                TypingIndicator()
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        // Auto-scroll to latest message
                        if let lastMessage = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Input
                ChatInput(
                    text: $messageText,
                    isFocused: $isInputFocused,
                    onSend: {
                        viewModel.sendMessage(messageText)
                        messageText = ""
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
            // Vivi Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 255/255, green: 127/255, blue: 110/255), // Coral
                                Color(red: 255/255, green: 191/255, blue: 105/255)  // Amber
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                
                Text("✨")
                    .font(.system(size: 20))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Vivi")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(red: 250/255, green: 247/255, blue: 242/255))
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color(red: 140/255, green: 200/255, blue: 120/255))
                        .frame(width: 8, height: 8)
                    
                    Text("Online")
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 200/255, green: 190/255, blue: 181/255))
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(red: 34/255, green: 28/255, blue: 23/255))
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer(minLength: 60)
            }
            
            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 8) {
                // Message content
                Text(message.text)
                    .font(.system(size: 16))
                    .foregroundColor(
                        message.isFromUser
                            ? Color(red: 10/255, green: 8/255, blue: 6/255)
                            : Color(red: 250/255, green: 247/255, blue: 242/255)
                    )
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        message.isFromUser
                            ? AnyView(
                                LinearGradient(
                                    colors: [
                                        Color(red: 255/255, green: 127/255, blue: 110/255),
                                        Color(red: 255/255, green: 191/255, blue: 105/255)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            : AnyView(Color(red: 42/255, green: 36/255, blue: 32/255))
                    )
                    .cornerRadius(20)
                
                // Timestamp
                Text(message.timestamp, style: .time)
                    .font(.system(size: 11))
                    .foregroundColor(Color(red: 140/255, green: 130/255, blue: 120/255))
            }
            
            if !message.isFromUser {
                Spacer(minLength: 60)
            }
        }
        .transition(.asymmetric(
            insertion: .scale(scale: 0.8).combined(with: .opacity),
            removal: .opacity
        ))
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: message.id)
    }
}

// MARK: - Typing Indicator

struct TypingIndicator: View {
    @State private var animationPhase = 0
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color(red: 200/255, green: 190/255, blue: 181/255))
                    .frame(width: 8, height: 8)
                    .scaleEffect(animationPhase == index ? 1.2 : 0.8)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: animationPhase
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(red: 42/255, green: 36/255, blue: 32/255))
        .cornerRadius(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            animationPhase = 0
        }
    }
}

// MARK: - Chat Input

struct ChatInput: View {
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding
    let onSend: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Text field
            TextField("Message Vivi...", text: $text)
                .font(.system(size: 16))
                .foregroundColor(Color(red: 250/255, green: 247/255, blue: 242/255))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(red: 42/255, green: 36/255, blue: 32/255))
                .cornerRadius(24)
                .focused(isFocused)
                .onSubmit(onSend)
            
            // Send button
            Button(action: onSend) {
                ZStack {
                    Circle()
                        .fill(
                            text.isEmpty
                                ? Color(red: 60/255, green: 55/255, blue: 50/255)
                                : LinearGradient(
                                    colors: [
                                        Color(red: 255/255, green: 127/255, blue: 110/255),
                                        Color(red: 255/255, green: 191/255, blue: 105/255)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                        )
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "arrow.up")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(
                            text.isEmpty
                                ? Color(red: 140/255, green: 130/255, blue: 120/255)
                                : Color(red: 10/255, green: 8/255, blue: 6/255)
                        )
                }
            }
            .disabled(text.isEmpty)
            .animation(.spring(response: 0.3), value: text.isEmpty)
        }
        .padding()
        .background(Color(red: 34/255, green: 28/255, blue: 23/255))
    }
}

// MARK: - Preview

#Preview {
    ViviChatView()
}
