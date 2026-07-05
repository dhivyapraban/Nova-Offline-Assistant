import '../repositories/ai_repository.dart';
import '../entities/ai_response.dart';

class ProcessInput {
  final AIRepository repository;
  ProcessInput(this.repository);

  Future<AIResponse> call(String input) async {
    return await repository.processInput(input);
  }
}
