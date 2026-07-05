import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../../data/datasources/todo_local_datasource.dart';
import '../../data/repository_impl/todo_repository_impl.dart';

final todoRepositoryProvider = Provider<TodoRepository>((ref) => TodoRepositoryImpl(TodoLocalDatasource()));

final todoControllerProvider = StateNotifierProvider<TodoController, AsyncValue<List<Todo>>>((ref) =>
  TodoController(ref.read(todoRepositoryProvider)));

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

class TodoController extends StateNotifier<AsyncValue<List<Todo>>> {
  final TodoRepository _repository;
  static const _uuid = Uuid();
  TodoController(this._repository) : super(const AsyncValue.loading()) { _load(); }

  Future<void> _load() async {
    try { state = AsyncValue.data(await _repository.getAll()); }
    catch (e, st) { state = AsyncValue.error(e, st); }
  }

  Future<void> addTodo({required String title, String? category, int priority = 0}) async {
    final now = DateTime.now();
    final todo = Todo(id: _uuid.v4(), title: title, category: category,
      priority: priority, createdAt: now, updatedAt: now);
    await _repository.create(todo);
    await _load();
  }

  Future<void> toggleComplete(String id) async { await _repository.toggleComplete(id); await _load(); }
  Future<void> deleteTodo(String id) async { await _repository.delete(id); await _load(); }
  Future<void> search(String query) async {
    if (query.isEmpty) { await _load(); return; }
    try { state = AsyncValue.data(await _repository.search(query)); }
    catch (e, st) { state = AsyncValue.error(e, st); }
  }
}
