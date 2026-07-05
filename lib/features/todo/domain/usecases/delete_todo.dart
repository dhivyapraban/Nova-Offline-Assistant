import '../repositories/todo_repository.dart';

class DeleteTodo { final TodoRepository r; DeleteTodo(this.r); Future<void> call(String id) => r.delete(id); }
