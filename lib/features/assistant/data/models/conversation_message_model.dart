import '../../domain/entities/conversation_message.dart';

class ConversationMessageModel extends ConversationMessage {
  const ConversationMessageModel({
    required super.id,
    required super.role,
    required super.content,
    super.intent,
    super.actionJson,
    required super.createdAt,
  });

  factory ConversationMessageModel.fromMap(Map<String, dynamic> map) {
    return ConversationMessageModel(
      id: map['id'] as String,
      role: map['role'] as String,
      content: map['content'] as String,
      intent: map['intent'] as String?,
      actionJson: map['action_json'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'role': role,
      'content': content,
      'intent': intent,
      'action_json': actionJson,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ConversationMessageModel.fromEntity(ConversationMessage entity) {
    return ConversationMessageModel(
      id: entity.id,
      role: entity.role,
      content: entity.content,
      intent: entity.intent,
      actionJson: entity.actionJson,
      createdAt: entity.createdAt,
    );
  }
}
