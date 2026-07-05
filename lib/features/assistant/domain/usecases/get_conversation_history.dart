import '../repositories/conversation_repository.dart';
import '../entities/conversation_message.dart';

class GetConversationHistory {
  final ConversationRepository repository;
  GetConversationHistory(this.repository);

  Future<List<ConversationMessage>> call({int limit = 50}) async {
    return await repository.getRecentMessages(limit: limit);
  }
}
