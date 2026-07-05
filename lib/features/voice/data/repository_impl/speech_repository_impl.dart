import 'dart:async';

import '../../domain/entities/speech_result.dart';
import '../../domain/repositories/speech_repository.dart';
import '../datasources/speech_recognition_service.dart';

/// Implementation of SpeechRepository using a SpeechRecognitionService
class SpeechRepositoryImpl implements SpeechRepository {
  final SpeechRecognitionService _recognitionService;
  StreamSubscription<SpeechResult>? _subscription;
  final _speechStreamController = StreamController<SpeechResult>.broadcast();

  SpeechRepositoryImpl(this._recognitionService) {
    _subscription = _recognitionService.recognitionStream.listen(
      (result) => _speechStreamController.add(result),
      onError: (error) => _speechStreamController.addError(error),
    );
  }

  @override
  Future<SpeechResult?> startListening() async {
    return _recognitionService.startRecognition();
  }

  @override
  Future<void> stopListening() async {
    await _recognitionService.stopRecognition();
  }

  @override
  Stream<SpeechResult> get speechStream => _speechStreamController.stream;

  @override
  bool get isListening => _recognitionService.isRecognizing;

  /// Clean up resources
  Future<void> dispose() async {
    await _subscription?.cancel();
    await _speechStreamController.close();
    await _recognitionService.dispose();
  }
}
