import '../repositories/notes_repository.dart';

class TogglePin {
  final NotesRepository _repository;

  TogglePin(this._repository);

  Future<void> call(String id) async {
    await _repository.togglePin(id);
  }
}
