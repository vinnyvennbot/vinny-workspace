import OpenAI from 'openai';

/**
 * Vivi AI Service
 * Powers conversational onboarding and recommendations using OpenAI GPT-4
 */
export class ViviService {
  private client: OpenAI;
  private model = 'gpt-4-turbo-preview';

  constructor(apiKey: string) {
    this.client = new OpenAI({ apiKey });
  }

  /**
   * Generate Vivi response to user message
   * @param userMessage - The user's message
   * @param conversationHistory - Previous messages in the conversation
   * @returns Vivi's response
   */
  async chat(
    userMessage: string,
    conversationHistory: Array<{ role: 'user' | 'assistant'; content: string }> = []
  ): Promise<string> {
    try {
      // Build messages array
      const messages: OpenAI.ChatCompletionMessageParam[] = [
        {
          role: 'system',
          content: this.getViviSystemPrompt()
        },
        ...conversationHistory.map(msg => ({
          role: msg.role,
          content: msg.content
        })),
        {
          role: 'user',
          content: userMessage
        }
      ];

      // Call OpenAI GPT-4
      const response = await this.client.chat.completions.create({
        model: this.model,
        messages,
        max_tokens: 1024,
        temperature: 0.8, // More creative/conversational
      });

      // Extract response text
      const reply = response.choices[0]?.message?.content;
      if (!reply) {
        throw new Error('No response from OpenAI');
      }

      return reply;
    } catch (error: any) {
      console.error('Vivi chat error:', error);
      throw new Error(`Failed to get Vivi response: ${error.message}`);
    }
  }

  /**
   * Get Vivi's system prompt
   * Defines personality, knowledge, and behavior
   */
  private getViviSystemPrompt(): string {
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
