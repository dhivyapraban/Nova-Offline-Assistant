import '../entities/note.dart';
import '../repositories/notes_repository.dart';

class SearchNotes {
  final NotesRepository _repository;

  SearchNotes(this._repository);

  Future<List<Note>> call(String query) async {
    return await _repository.search(query);
  }
}
