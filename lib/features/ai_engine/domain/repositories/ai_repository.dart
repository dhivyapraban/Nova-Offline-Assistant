import '../entities/ai_response.dart';
import '../entities/intent.dart';

abstract class AIRepository {
  Future<AIResponse> processInput(String input);
  Future<Intent> parseIntent(String input);
  Future<void> initialize();
  bool get isReady;
}
