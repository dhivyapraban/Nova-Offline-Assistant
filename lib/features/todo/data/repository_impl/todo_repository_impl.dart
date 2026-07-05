import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/todo_local_datasource.dart';
import '../models/todo_model.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoLocalDatasource _ds;
  TodoRepositoryImpl(this._ds);

  @override Future<List<Todo>> getAll() => _ds.getAll();
  @override Future<Todo> create(Todo t) async { await _ds.insert(TodoModel.fromEntity(t)); return t; }
  @override Future<void> update(Todo t) => _ds.update(TodoModel.fromEntity(t));
  @override Future<void> delete(String id) => _ds.delete(id);
  @override Future<List<Todo>> search(String q) => _ds.search(q);

  @override
  Future<void> toggleComplete(String id) async {
    final all = await _ds.getAll();
    final t = all.firstWhere((e) => e.id == id);
    await _ds.update(TodoModel.fromEntity(t.copyWith(isCompleted: !t.isCompleted, updatedAt: DateTime.now())));
  }
}
