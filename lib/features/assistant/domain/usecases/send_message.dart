import '../repositories/conversation_repository.dart';
import '../entities/conversation_message.dart';

class SendMessage {
  final ConversationRepository repository;
  SendMessage(this.repository);

  Future<ConversationMessage> call(ConversationMessage message) async {
    return await repository.addMessage(message);
  }
}
