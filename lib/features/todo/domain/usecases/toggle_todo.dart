import '../repositories/todo_repository.dart';

class ToggleTodo { final TodoRepository r; ToggleTodo(this.r); Future<void> call(String id) => r.toggleComplete(id); }
