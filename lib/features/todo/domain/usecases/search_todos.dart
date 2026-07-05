import '../repositories/todo_repository.dart';
import '../entities/todo.dart';

class SearchTodos { final TodoRepository r; SearchTodos(this.r); Future<List<Todo>> call(String q) => r.search(q); }
