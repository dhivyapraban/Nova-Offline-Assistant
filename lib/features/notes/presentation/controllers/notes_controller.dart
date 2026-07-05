import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';
import '../../data/datasources/notes_local_datasource.dart';
import '../../data/repository_impl/notes_repository_impl.dart';

// === Providers ===

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepositoryImpl(NotesLocalDatasource());
});

final notesControllerProvider =
    StateNotifierProvider<NotesController, AsyncValue<List<Note>>>((ref) {
  return NotesController(ref.read(notesRepositoryProvider));
});

final notesSearchQueryProvider = StateProvider<String>((ref) => '');

final notesViewModeProvider = StateProvider<NotesViewMode>((ref) => NotesViewMode.grid);

final filteredNotesProvider = Provider<AsyncValue<List<Note>>>((ref) {
  final query = ref.watch(notesSearchQueryProvider);
  final notesAsync = ref.watch(notesControllerProvider);

  return notesAsync.whenData((notes) {
    if (query.isEmpty) return notes;
    final lowerQuery = query.toLowerCase();
    return notes.where((note) {
      return note.title.toLowerCase().contains(lowerQuery) ||
          note.content.toLowerCase().contains(lowerQuery);
    }).toList();
  });
});

final pinnedNotesProvider = Provider<List<Note>>((ref) {
  final filtered = ref.watch(filteredNotesProvider);
  return filtered.whenOrNull(data: (notes) => notes.where((n) => n.isPinned).toList()) ?? [];
});

final unpinnedNotesProvider = Provider<List<Note>>((ref) {
  final filtered = ref.watch(filteredNotesProvider);
  return filtered.whenOrNull(data: (notes) => notes.where((n) => !n.isPinned).toList()) ?? [];
});

enum NotesViewMode { grid, list }

// === Controller ===

class NotesController extends StateNotifier<AsyncValue<List<Note>>> {
  final NotesRepository _repository;
  static const _uuid = Uuid();

  NotesController(this._repository) : super(const AsyncValue.loading()) {
    loadNotes();
  }

  Future<void> loadNotes() async {
    state = const AsyncValue.loading();
    try {
      final notes = await _repository.getAll();
      state = AsyncValue.data(notes);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createNote({
    required String title,
    required String content,
    int? color,
    bool isPinned = false,
  }) async {
    try {
      final now = DateTime.now();
      final note = Note(
        id: _uuid.v4(),
        title: title,
        content: content,
        isPinned: isPinned,
        color: color,
        createdAt: now,
        updatedAt: now,
      );
      await _repository.create(note);
      await loadNotes();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateNote(Note note) async {
    try {
      final updated = note.copyWith(updatedAt: DateTime.now());
      await _repository.update(updated);
      await loadNotes();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await _repository.delete(id);
      await loadNotes();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> togglePin(String id) async {
    try {
      await _repository.togglePin(id);
      await loadNotes();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Note?> getNoteById(String id) async {
    try {
      return await _repository.getById(id);
    } catch (_) {
      return null;
    }
  }
}
