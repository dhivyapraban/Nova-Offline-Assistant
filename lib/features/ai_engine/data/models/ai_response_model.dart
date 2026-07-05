import '../../domain/entities/ai_response.dart';

class AIResponseModel extends AIResponse {
  const AIResponseModel({
    required super.text,
    super.intent,
    super.actionData,
    required super.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'text': text,
    'intent': intent,
    'timestamp': timestamp.toIso8601String(),
  };

  factory AIResponseModel.fromMap(Map<String, dynamic> map) {
    return AIResponseModel(
      text: map['text'] as String,
      intent: map['intent'] as String?,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}
