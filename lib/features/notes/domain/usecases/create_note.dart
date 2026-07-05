import '../entities/note.dart';
import '../repositories/notes_repository.dart';

class CreateNote {
  final NotesRepository _repository;

  CreateNote(this._repository);

  Future<void> call(Note note) async {
    await _repository.create(note);
  }
}
