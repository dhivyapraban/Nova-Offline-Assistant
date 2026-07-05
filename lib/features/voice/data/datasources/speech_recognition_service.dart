import '../../domain/entities/speech_result.dart';

/// Abstract interface for speech recognition services.
///
/// This defines the contract that any speech recognition backend
/// (Whisper.cpp, Google, etc.) must implement.
abstract class SpeechRecognitionService {
  /// Initialize the speech recognition engine
  Future<void> initialize();

  /// Start recognizing speech from audio input
  Future<SpeechResult?> startRecognition();

  /// Stop recognizing speech
  Future<void> stopRecognition();

  /// Stream of real-time recognition results
  Stream<SpeechResult> get recognitionStream;

  /// Whether the service is currently recognizing
  bool get isRecognizing;

  /// Whether the service has been initialized
  bool get isInitialized;

  /// Dispose resources
  Future<void> dispose();
}
