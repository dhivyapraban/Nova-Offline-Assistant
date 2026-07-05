class ConversationMessage {
  final String id;
  final String role; // 'user' or 'assistant'
  final String content;
  final String? intent;
  final String? actionJson;
  final DateTime createdAt;

  const ConversationMessage({
    required this.id,
    required this.role,
    required this.content,
    this.intent,
    this.actionJson,
    required this.createdAt,
  });

  ConversationMessage copyWith({
    String? id,
    String? role,
    String? content,
    String? intent,
    String? actionJson,
    DateTime? createdAt,
  }) {
    return ConversationMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      intent: intent ?? this.intent,
      actionJson: actionJson ?? this.actionJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationMessage && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
