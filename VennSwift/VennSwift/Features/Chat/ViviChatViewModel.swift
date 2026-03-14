import Foundation
import Combine

/// Chat message model
struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
    let timestamp: Date
}

/// Vivi Chat ViewModel
/// Handles conversation logic and Claude API integration
@MainActor
class ViviChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isTyping = false
    
    private let apiBaseURL = "http://localhost:4000" // venn-ai-backend
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Methods
    
    /// Send welcome message on first load
    func sendWelcomeMessage() {
        guard messages.isEmpty else { return }
        
        let welcomeText = """
        Hey! I'm Vivi 👋
        
        I'm here to help you discover amazing things to do in San Francisco.
        
        Tell me — what brings you joy? What kind of experiences are you looking for?
        """
        
        addMessage(text: welcomeText, isFromUser: false)
    }
    
    /// Send user message and get Vivi's response
    func sendMessage(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Add user message
        addMessage(text: text, isFromUser: true)
        
        // Get Vivi's response
        Task {
            await getViviResponse(userMessage: text)
        }
    }
    
    // MARK: - Private Methods
    
    private func addMessage(text: String, isFromUser: Bool) {
        let message = ChatMessage(
            text: text,
            isFromUser: isFromUser,
            timestamp: Date()
        )
        messages.append(message)
    }
    
    private func getViviResponse(userMessage: String) async {
        isTyping = true
        
        // Simulate network delay for now (will replace with real API call)
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        isTyping = false
        
        // Mock response based on user input
        let response = generateMockResponse(for: userMessage)
        addMessage(text: response, isFromUser: false)
    }
    
    /// Generate mock response until Claude API is integrated
    private func generateMockResponse(for userMessage: String) -> String {
        let lowercased = userMessage.lowercased()
        
        if lowercased.contains("music") || lowercased.contains("concert") {
            return """
            Love it! Music is the soul of SF 🎵
            
            I'm thinking you'd vibe with intimate live shows at places like The Chapel or Café Du Nord. Jazz? Rock? Electronic?
            
            Also — there's a sick underground house party happening Saturday at an undisclosed warehouse. Want details?
            """
        }
        
        if lowercased.contains("food") || lowercased.contains("dinner") {
            return """
            Ooh, a foodie! 🍽️
            
            SF has some incredible hidden gems. Are you feeling:
            • Cozy date night vibes?
            • Adventurous group dinner?
            • Something Instagram-worthy?
            
            I know a secret speakeasy with a Michelin-level chef...
            """
        }
        
        if lowercased.contains("dance") || lowercased.contains("party") {
            return """
            Let's get you moving! 💃
            
            This weekend:
            • Silent disco at Fort Mason (bring headphones)
            • Salsa night at Roccapulco (free lessons at 8pm)
            • Underground techno at The Midway
            
            Which vibe calls to you?
            """
        }
        
        if lowercased.contains("chill") || lowercased.contains("relax") {
            return """
            I feel you — sometimes you just need low-key magic ✨
            
            How about:
            • Sunset picnic at Dolores Park?
            • Rooftop cocktails at El Techo?
            • Late-night coffee + poetry at Red Window?
            
            What sounds good?
            """
        }
        
        // Default exploratory response
        return """
        I love that! Tell me more about what kind of vibe you're going for:
        
        🎭 Are you more adventurous or laid-back?
        👥 Solo, with friends, or meeting new people?
        🌃 Weeknight wind-down or weekend wild?
        
        The more I know, the better I can find your perfect night.
        """
    }
}

// MARK: - API Integration (Coming Soon)

extension ViviChatViewModel {
    /// Call venn-ai-backend Vivi chat endpoint
    /// POST /api/vivi/chat
    private func callViviAPI(userMessage: String) async throws -> String {
        guard let url = URL(string: "\(apiBaseURL)/api/vivi/chat") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "message": userMessage,
            "conversationHistory": messages.map { msg in
                [
                    "role": msg.isFromUser ? "user" : "assistant",
                    "content": msg.text
                ]
            }
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let response = json["response"] as? String {
            return response
        }
        
        throw URLError(.cannotParseResponse)
    }
}
