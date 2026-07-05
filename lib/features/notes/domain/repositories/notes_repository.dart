import '../entities/note.dart';

/// Abstract repository for notes operations
abstract class NotesRepository {
  Future<List<Note>> getAll();
  Future<Note?> getById(String id);
  Future<void> create(Note note);
  Future<void> update(Note note);
  Future<void> delete(String id);
  Future<List<Note>> search(String query);
  Future<void> togglePin(String id);
}
