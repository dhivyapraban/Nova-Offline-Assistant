import '../repositories/ai_repository.dart';
import '../entities/intent.dart';

class ParseIntent {
  final AIRepository repository;
  ParseIntent(this.repository);

  Future<Intent> call(String input) async {
    return await repository.parseIntent(input);
  }
}
