import 'package:nova_assistant/core/services/database_service.dart';
import '../models/conversation_message_model.dart';

class ConversationLocalDatasource {
  Future<List<ConversationMessageModel>> getAll() async {
    final db = await DatabaseService.instance.database;
    final maps = await db.query('conversation_history', orderBy: 'created_at ASC');
    return maps.map((m) => ConversationMessageModel.fromMap(m)).toList();
  }

  Future<List<ConversationMessageModel>> getRecent({int limit = 20}) async {
    final db = await DatabaseService.instance.database;
    final maps = await db.query(
      'conversation_history',
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return maps.map((m) => ConversationMessageModel.fromMap(m)).toList().reversed.toList();
  }

  Future<void> insert(ConversationMessageModel message) async {
    final db = await DatabaseService.instance.database;
    await db.insert('conversation_history', message.toMap());
  }

  Future<void> clearAll() async {
    final db = await DatabaseService.instance.database;
    await db.delete('conversation_history');
  }
}
