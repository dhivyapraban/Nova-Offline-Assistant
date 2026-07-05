import 'package:nova_assistant/core/services/database_service.dart';
import '../models/todo_model.dart';

class TodoLocalDatasource {
  Future<List<TodoModel>> getAll() async {
    final db = await DatabaseService.instance.database;
    final maps = await db.query('todos', orderBy: 'created_at DESC');
    return maps.map((m) => TodoModel.fromMap(m)).toList();
  }

  Future<void> insert(TodoModel todo) async {
    final db = await DatabaseService.instance.database;
    await db.insert('todos', todo.toMap());
  }

  Future<void> update(TodoModel todo) async {
    final db = await DatabaseService.instance.database;
    await db.update('todos', todo.toMap(), where: 'id = ?', whereArgs: [todo.id]);
  }

  Future<void> delete(String id) async {
    final db = await DatabaseService.instance.database;
    await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<TodoModel>> search(String query) async {
    final db = await DatabaseService.instance.database;
    final maps = await db.query('todos', where: 'title LIKE ?', whereArgs: ['%$query%']);
    return maps.map((m) => TodoModel.fromMap(m)).toList();
  }
}
