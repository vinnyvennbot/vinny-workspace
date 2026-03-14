import { ViviService } from './vivi';

describe('ViviService', () => {
  let vivi: ViviService;

  beforeAll(() => {
    const apiKey = process.env.ANTHROPIC_API_KEY;
    if (!apiKey) {
      console.warn('ANTHROPIC_API_KEY not set - skipping Vivi tests');
      return;
    }
    vivi = new ViviService(apiKey);
  });

  const skipIfNoKey = process.env.ANTHROPIC_API_KEY ? it : it.skip;

  describe('chat', () => {
    skipIfNoKey('should generate response to simple question', async () => {
      const response = await vivi.chat("What's happening in SF tonight?");
      
      expect(typeof response).toBe('string');
      expect(response.length).toBeGreaterThan(0);
    }, 30000); // 30 second timeout for API call

    skipIfNoKey('should handle conversation history', async () => {
      const history = [
        { role: 'user' as const, content: "I like jazz music" },
        { role: 'assistant' as const, content: "Great! SF has amazing jazz venues." }
      ];

      const response = await vivi.chat("What do you recommend?", history);
      
      expect(typeof response).toBe('string');
      expect(response.length).toBeGreaterThan(0);
      // Response should reference jazz (context from history)
      expect(response.toLowerCase()).toContain('jazz');
    }, 30000);

    it('should throw error with invalid API key', async () => {
      const badVivi = new ViviService('invalid-key');
      
      await expect(badVivi.chat("Hello")).rejects.toThrow();
    }, 10000);
  });

  describe('personality', () => {
    skipIfNoKey('should respond conversationally', async () => {
      const response = await vivi.chat("Hey Vivi!");
      
      // Should be warm and friendly (not robotic)
      expect(response.toLowerCase()).toMatch(/hey|hi|hello|what's up/);
    }, 30000);

    skipIfNoKey('should ask follow-up questions', async () => {
      const response = await vivi.chat("I want to go out tonight");
      
      // Should ask about preferences
      expect(response).toMatch(/\?/); // Contains a question
    }, 30000);
  });
});
