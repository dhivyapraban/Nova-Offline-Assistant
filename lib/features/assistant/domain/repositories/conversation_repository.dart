import '../entities/conversation_message.dart';

abstract class ConversationRepository {
  Future<List<ConversationMessage>> getHistory();
  Future<ConversationMessage> addMessage(ConversationMessage message);
  Future<void> clearHistory();
  Future<List<ConversationMessage>> getRecentMessages({int limit = 20});
}
