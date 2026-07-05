import '../entities/note.dart';
import '../repositories/notes_repository.dart';

class UpdateNote {
  final NotesRepository _repository;

  UpdateNote(this._repository);

  Future<void> call(Note note) async {
    await _repository.update(note);
  }
}
