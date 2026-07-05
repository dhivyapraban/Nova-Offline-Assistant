import '../entities/speech_result.dart';

/// Abstract repository for speech recognition operations
abstract class SpeechRepository {
  /// Start listening for speech input
  Future<SpeechResult?> startListening();

  /// Stop listening for speech input
  Future<void> stopListening();

  /// Stream of speech recognition results
  Stream<SpeechResult> get speechStream;

  /// Whether the recognizer is currently listening
  bool get isListening;
}
