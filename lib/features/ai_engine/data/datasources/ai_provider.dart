/// Abstract AI provider interface for future LLM integration
/// Implementations: RuleBasedProvider (current), LocalLLMProvider (future)
abstract class AIProvider {
  Future<String> generateResponse(String input, {List<Map<String, String>>? context});
  Future<void> initialize();
  bool get isReady;
  String get providerName;
}
