import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../../data/datasources/reminder_local_datasource.dart';
import '../../data/repository_impl/reminder_repository_impl.dart';

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) =>
  ReminderRepositoryImpl(ReminderLocalDatasource()));

final reminderControllerProvider = StateNotifierProvider<ReminderController, AsyncValue<List<Reminder>>>((ref) =>
  ReminderController(ref.read(reminderRepositoryProvider)));

class ReminderController extends StateNotifier<AsyncValue<List<Reminder>>> {
  final ReminderRepository _repository;
  static const _uuid = Uuid();
  ReminderController(this._repository) : super(const AsyncValue.loading()) { _load(); }

  Future<void> _load() async {
    try { state = AsyncValue.data(await _repository.getAll()); }
    catch (e, st) { state = AsyncValue.error(e, st); }
  }

  Future<void> addReminder({required String title, String? description, required DateTime remindAt}) async {
    final reminder = Reminder(id: _uuid.v4(), title: title, description: description,
      remindAt: remindAt, createdAt: DateTime.now());
    await _repository.create(reminder);
    await _load();
  }

  Future<void> deleteReminder(String id) async {
    await _repository.delete(id);
    await _load();
  }

  Future<void> toggleComplete(String id) async {
    await _repository.toggleComplete(id);
    await _load();
  }
}
