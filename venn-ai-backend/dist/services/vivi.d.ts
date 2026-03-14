/**
 * Vivi AI Service
 * Powers conversational onboarding and recommendations using OpenAI GPT-4
 */
export declare class ViviService {
    private client;
    private model;
    constructor(apiKey: string);
    /**
     * Generate Vivi response to user message
     * @param userMessage - The user's message
     * @param conversationHistory - Previous messages in the conversation
     * @returns Vivi's response
     */
    chat(userMessage: string, conversationHistory?: Array<{
        role: 'user' | 'assistant';
        content: string;
    }>): Promise<string>;
    /**
     * Get Vivi's system prompt
     * Defines personality, knowledge, and behavior
     */
    private getViviSystemPrompt;
}
//# sourceMappingURL=vivi.d.ts.map