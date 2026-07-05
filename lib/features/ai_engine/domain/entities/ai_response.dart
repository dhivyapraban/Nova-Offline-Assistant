class AIResponse {
  final String text;
  final String? intent;
  final Map<String, dynamic>? actionData;
  final DateTime timestamp;

  const AIResponse({
    required this.text,
    this.intent,
    this.actionData,
    required this.timestamp,
  });

  AIResponse copyWith({
    String? text,
    String? intent,
    Map<String, dynamic>? actionData,
    DateTime? timestamp,
  }) {
    return AIResponse(
      text: text ?? this.text,
      intent: intent ?? this.intent,
      actionData: actionData ?? this.actionData,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
