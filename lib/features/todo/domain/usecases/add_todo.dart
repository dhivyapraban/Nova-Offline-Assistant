import '../repositories/todo_repository.dart';
import '../entities/todo.dart';

class AddTodo { final TodoRepository r; AddTodo(this.r); Future<Todo> call(Todo t) => r.create(t); }
