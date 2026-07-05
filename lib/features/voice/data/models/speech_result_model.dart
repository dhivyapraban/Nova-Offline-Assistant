import '../../domain/entities/speech_result.dart';

/// Model extending SpeechResult with serialization for SQLite
class SpeechResultModel extends SpeechResult {
  const SpeechResultModel({
    required super.text,
    required super.confidence,
    required super.isFinal,
    required super.timestamp,
  });

  /// Create from a Map (e.g., from SQLite or JSON)
  factory SpeechResultModel.fromMap(Map<String, dynamic> map) {
    return SpeechResultModel(
      text: map['text'] as String? ?? '',
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
      isFinal: (map['is_final'] as int?) == 1,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  /// Create from a domain entity
  factory SpeechResultModel.fromEntity(SpeechResult entity) {
    return SpeechResultModel(
      text: entity.text,
      confidence: entity.confidence,
      isFinal: entity.isFinal,
      timestamp: entity.timestamp,
    );
  }

  /// Convert to a Map for SQLite storage
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'confidence': confidence,
      'is_final': isFinal ? 1 : 0,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
