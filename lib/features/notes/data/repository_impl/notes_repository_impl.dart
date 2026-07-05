import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';
import '../datasources/notes_local_datasource.dart';
import '../models/note_model.dart';

/// Concrete implementation of NotesRepository using local SQLite
class NotesRepositoryImpl implements NotesRepository {
  final NotesLocalDatasource _datasource;

  NotesRepositoryImpl(this._datasource);

  @override
  Future<List<Note>> getAll() async {
    return await _datasource.getAll();
  }

  @override
  Future<Note?> getById(String id) async {
    return await _datasource.getById(id);
  }

  @override
  Future<void> create(Note note) async {
    await _datasource.insert(NoteModel.fromEntity(note));
  }

  @override
  Future<void> update(Note note) async {
    await _datasource.update(NoteModel.fromEntity(note));
  }

  @override
  Future<void> delete(String id) async {
    await _datasource.delete(id);
  }

  @override
  Future<List<Note>> search(String query) async {
    return await _datasource.search(query);
  }

  @override
  Future<void> togglePin(String id) async {
    await _datasource.togglePin(id);
  }
}
