import '../entities/speech_result.dart';
import '../repositories/speech_repository.dart';

/// Use case to start listening for speech input
class StartListening {
  final SpeechRepository _repository;

  StartListening(this._repository);

  Future<SpeechResult?> call() => _repository.startListening();

  Stream<SpeechResult> get speechStream => _repository.speechStream;
}
