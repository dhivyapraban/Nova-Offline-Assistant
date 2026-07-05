import 'dart:async';
import 'dart:math';

import '../../domain/entities/speech_result.dart';
import 'speech_recognition_service.dart';

/// Placeholder implementation of SpeechRecognitionService using Whisper.cpp.
///
/// Currently returns simulated results for development/testing.
/// TODO: Integrate actual Whisper.cpp via FFI when native bindings are ready.
/// TODO: Steps for future FFI integration:
///   1. Build whisper.cpp shared library for Android (libwhisper.so)
///   2. Create dart:ffi bindings in lib/core/ffi/whisper_bindings.dart
///   3. Load and manage the Whisper model (e.g., ggml-base.en.bin)
///   4. Feed PCM audio frames from AudioRecorderService into Whisper
///   5. Parse Whisper JSON output into SpeechResult objects
class WhisperSpeechService implements SpeechRecognitionService {
  bool _isRecognizing = false;
  bool _isInitialized = false;
  Timer? _simulationTimer;
  final _streamController = StreamController<SpeechResult>.broadcast();
  final _random = Random();

  /// Simulated responses for testing
  static const _simulatedPhrases = [
    'Hello Nova, how are you today?',
    'Set a timer for 5 minutes',
    'Create a note titled shopping list',
    'What time is it?',
    'Play some music',
    'Remind me to call mom at 3 PM',
    'Add buy groceries to my todo list',
    'Good morning Nova',
    'Open the settings',
    'Search for documents about Flutter',
  ];

  @override
  Future<void> initialize() async {
    // TODO: Load Whisper model via FFI
    // final modelPath = await _getModelPath();
    // _whisperContext = whisper_init_from_file(modelPath);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _isInitialized = true;
  }

  @override
  Future<SpeechResult?> startRecognition() async {
    if (!_isInitialized) await initialize();
    _isRecognizing = true;

    // Simulate speech recognition with delayed results
    _simulationTimer = Timer(
      Duration(milliseconds: 1500 + _random.nextInt(2000)),
      () {
        if (_isRecognizing) {
          final phrase =
              _simulatedPhrases[_random.nextInt(_simulatedPhrases.length)];

          // Emit partial results first
          final partialResult = SpeechResult(
            text: phrase.substring(0, (phrase.length * 0.6).toInt()),
            confidence: 0.5 + _random.nextDouble() * 0.3,
            isFinal: false,
            timestamp: DateTime.now(),
          );
          _streamController.add(partialResult);

          // Then emit final result
          Future<void>.delayed(const Duration(milliseconds: 500), () {
            if (_isRecognizing) {
              final finalResult = SpeechResult(
                text: phrase,
                confidence: 0.85 + _random.nextDouble() * 0.15,
                isFinal: true,
                timestamp: DateTime.now(),
              );
              _streamController.add(finalResult);
            }
          });
        }
      },
    );

    return null; // Results come via stream
  }

  @override
  Future<void> stopRecognition() async {
    _isRecognizing = false;
    _simulationTimer?.cancel();
    _simulationTimer = null;
  }

  @override
  Stream<SpeechResult> get recognitionStream => _streamController.stream;

  @override
  bool get isRecognizing => _isRecognizing;

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> dispose() async {
    await stopRecognition();
    await _streamController.close();
    // TODO: whisper_free(_whisperContext);
  }
}
