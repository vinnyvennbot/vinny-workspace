/**
 * Vivi AI Service
 * Powers conversational onboarding and recommendations using Claude Sonnet 4
 */
export declare class ViviService {
    private client;
    private model;
    constructor(apiKey: string);
    /**
     * Generate Vivi response to user message
     */
    chat(userMessage: string, conversationHistory?: Array<{
        role: 'user' | 'assistant';
        content: string;
    }>): Promise<string>;
    private getViviSystemPrompt;
}
//# sourceMappingURL=vivi.d.ts.map