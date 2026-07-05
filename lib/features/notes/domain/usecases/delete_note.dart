import '../repositories/notes_repository.dart';

class DeleteNote {
  final NotesRepository _repository;

  DeleteNote(this._repository);

  Future<void> call(String id) async {
    await _repository.delete(id);
  }
}
