import 'package:nova_assistant/core/services/database_service.dart';

import '../models/note_model.dart';

/// Local SQLite datasource for notes
class NotesLocalDatasource {
  static const _table = 'notes';

  Future<List<NoteModel>> getAll() async {
    final db = await DatabaseService.instance.database;
    final maps = await db.query(
      _table,
      orderBy: 'is_pinned DESC, updated_at DESC',
    );
    return maps.map((map) => NoteModel.fromMap(map)).toList();
  }

  Future<NoteModel?> getById(String id) async {
    final db = await DatabaseService.instance.database;
    final maps = await db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return NoteModel.fromMap(maps.first);
  }

  Future<void> insert(NoteModel model) async {
    final db = await DatabaseService.instance.database;
    await db.insert(_table, model.toMap());
  }

  Future<void> update(NoteModel model) async {
    final db = await DatabaseService.instance.database;
    await db.update(
      _table,
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await DatabaseService.instance.database;
    await db.delete(
      _table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<NoteModel>> search(String query) async {
    final db = await DatabaseService.instance.database;
    final maps = await db.query(
      _table,
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'is_pinned DESC, updated_at DESC',
    );
    return maps.map((map) => NoteModel.fromMap(map)).toList();
  }

  Future<void> togglePin(String id) async {
    final db = await DatabaseService.instance.database;
    final maps = await db.query(
      _table,
      columns: ['is_pinned'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      final currentPinned = (maps.first['is_pinned'] as int) == 1;
      await db.update(
        _table,
        {'is_pinned': currentPinned ? 0 : 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }
}
