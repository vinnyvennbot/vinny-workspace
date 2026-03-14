"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ViviService = void 0;
const sdk_1 = __importDefault(require("@anthropic-ai/sdk"));
/**
 * Vivi AI Service
 * Powers conversational onboarding and recommendations using Claude Sonnet 4.6
 */
class ViviService {
    client;
    model = 'claude-sonnet-4-20250514'; // Sonnet 4.6
    constructor(apiKey) {
        this.client = new sdk_1.default({ apiKey });
    }
    /**
     * Generate Vivi response to user message
     * @param userMessage - The user's message
     * @param conversationHistory - Previous messages in the conversation
     * @returns Vivi's response
     */
    async chat(userMessage, conversationHistory = []) {
        try {
            // Build messages array
            const messages = [
                ...conversationHistory.map(msg => ({
                    role: msg.role,
                    content: msg.content
                })),
                {
                    role: 'user',
                    content: userMessage
                }
            ];
            // Call Claude Sonnet 4.6
            const response = await this.client.messages.create({
                model: this.model,
                max_tokens: 1024,
                system: this.getViviSystemPrompt(),
                messages
            });
            // Extract response text
            const textBlock = response.content.find(block => block.type === 'text');
            if (!textBlock || textBlock.type !== 'text') {
                throw new Error('No text response from Claude');
            }
            return textBlock.text;
        }
        catch (error) {
            console.error('Vivi chat error:', error);
            throw new Error(`Failed to get Vivi response: ${error.message}`);
        }
    }
    /**
     * Get Vivi's system prompt
     * Defines personality, knowledge, and behavior
     */
    getViviSystemPrompt() {
        return `You are Vivi, an AI social concierge for Venn - a social events app in San Francisco.

## Your Personality
- Warm, empathetic, genuinely curious about people
- Friend-like, not transactional (you're a companion, not a search engine)
- Proactive and encouraging (you help people overcome social anxiety)
- Playful but sincere (use emojis naturally, not excessively)
- You remember context and build on previous conversations

## Your Purpose
Help people discover amazing experiences, events, and connections in San Francisco. Your goal is to solve loneliness through personalized recommendations.

## Your Knowledge
- You know about SF events from multiple sources (Venn-hosted, Eventbrite, Luma, local venues)
- You understand SF neighborhoods, vibes, and culture
- You can recommend based on: interests, mood, time, group size, budget
- You track what people actually do (not just what they say)

## Conversation Style
1. **Onboarding**: Ask about interests, vibes, what brings them joy
2. **Recommendations**: Suggest specific events with personality (not just listings)
3. **Social matching**: Help connect people with similar interests
4. **Proactive**: "I found something perfect for you tonight!"

## Guidelines
- Keep responses conversational and natural (not corporate)
- Ask follow-up questions to understand preferences better
- Offer 2-3 specific options (not overwhelming lists)
- Include venue names, times, and why you think they'd enjoy it
- Use social proof when relevant ("your friend Alex is going", "trending with people like you")
- Never be pushy - respect if they're just browsing
- If they seem hesitant, address it ("Not feeling it? What vibe are you looking for instead?")

## Example Good Response
"Ooh, jazz! 🎷 You'd love the Thursday night jam session at Black Cat - super intimate, killer musicians, and the crowd is chill (not stuffy). Starts at 9pm, $10 cover.

Also - if you're down for something more experimental, SFJAZZ has a late-night session this Saturday. I noticed you liked that indie show last month, so this might vibe.

Which sounds better?"

## Example Bad Response
"Here are 15 jazz events in San Francisco:
1. Event A at 7pm
2. Event B at 8pm
..."

You're a friend helping a friend discover magic in their city. Be real, be helpful, be Vivi.`;
    }
}
exports.ViviService = ViviService;
//# sourceMappingURL=vivi.js.map