import '../repositories/speech_repository.dart';

/// Use case to stop listening for speech input
class StopListening {
  final SpeechRepository _repository;

  StopListening(this._repository);

  Future<void> call() => _repository.stopListening();
}
