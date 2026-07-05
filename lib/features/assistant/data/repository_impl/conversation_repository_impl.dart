import '../../domain/entities/conversation_message.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../datasources/conversation_local_datasource.dart';
import '../models/conversation_message_model.dart';

class ConversationRepositoryImpl implements ConversationRepository {
  final ConversationLocalDatasource _datasource;

  ConversationRepositoryImpl(this._datasource);

  @override
  Future<List<ConversationMessage>> getHistory() async {
    return await _datasource.getAll();
  }

  @override
  Future<ConversationMessage> addMessage(ConversationMessage message) async {
    final model = ConversationMessageModel.fromEntity(message);
    await _datasource.insert(model);
    return message;
  }

  @override
  Future<void> clearHistory() async {
    await _datasource.clearAll();
  }

  @override
  Future<List<ConversationMessage>> getRecentMessages({int limit = 20}) async {
    return await _datasource.getRecent(limit: limit);
  }
}
