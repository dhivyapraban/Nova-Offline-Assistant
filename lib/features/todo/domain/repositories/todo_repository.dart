import '../entities/todo.dart';

abstract class TodoRepository {
  Future<List<Todo>> getAll();
  Future<Todo> create(Todo todo);
  Future<void> update(Todo todo);
  Future<void> delete(String id);
  Future<void> toggleComplete(String id);
  Future<List<Todo>> search(String query);
}
