/// Represents a speech recognition result
class SpeechResult {
  final String text;
  final double confidence;
  final bool isFinal;
  final DateTime timestamp;

  const SpeechResult({
    required this.text,
    required this.confidence,
    required this.isFinal,
    required this.timestamp,
  });

  SpeechResult copyWith({
    String? text,
    double? confidence,
    bool? isFinal,
    DateTime? timestamp,
  }) {
    return SpeechResult(
      text: text ?? this.text,
      confidence: confidence ?? this.confidence,
      isFinal: isFinal ?? this.isFinal,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() =>
      'SpeechResult(text: $text, confidence: $confidence, isFinal: $isFinal)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpeechResult &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          confidence == other.confidence &&
          isFinal == other.isFinal &&
          timestamp == other.timestamp;

  @override
  int get hashCode =>
      text.hashCode ^
      confidence.hashCode ^
      isFinal.hashCode ^
      timestamp.hashCode;
}
