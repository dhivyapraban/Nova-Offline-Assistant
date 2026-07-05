import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../domain/entities/speech_result.dart';
import 'speech_recognition_service.dart';

/// Real implementation of SpeechRecognitionService using speech_to_text package.
/// Works offline on modern Android devices if offline packages are downloaded.
class SpeechToTextService implements SpeechRecognitionService {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isRecognizing = false;
  bool _isInitialized = false;
  final _streamController = StreamController<SpeechResult>.broadcast();

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      _isInitialized = await _speechToText.initialize(
        onError: (val) {
          _isRecognizing = false;
          _streamController.addError(val.errorMsg);
        },
        onStatus: (val) {
          if (val == 'listening') {
            _isRecognizing = true;
          } else if (val == 'notListening' || val == 'done') {
            _isRecognizing = false;
          }
        },
      );
    } catch (e) {
      _isInitialized = false;
      _streamController.addError(e.toString());
    }
  }

  @override
  Future<SpeechResult?> startRecognition() async {
    if (!_isInitialized) await initialize();
    if (!_isInitialized) {
      throw Exception('Speech recognition failed to initialize');
    }

    _isRecognizing = true;
    await _speechToText.listen(
      onResult: (result) {
        final speechResult = SpeechResult(
          text: result.recognizedWords,
          confidence: result.confidence,
          isFinal: result.finalResult,
          timestamp: DateTime.now(),
        );
        _streamController.add(speechResult);
      },
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.dictation,
        cancelOnError: true,
        partialResults: true,
      ),
    );

    return null;
  }

  @override
  Future<void> stopRecognition() async {
    if (_isRecognizing) {
      await _speechToText.stop();
      _isRecognizing = false;
    }
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
  }
}
