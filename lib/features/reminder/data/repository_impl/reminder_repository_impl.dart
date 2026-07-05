import '../../domain/entities/reminder.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../datasources/reminder_local_datasource.dart';
import '../models/reminder_model.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  final ReminderLocalDatasource _datasource;
  ReminderRepositoryImpl(this._datasource);

  @override
  Future<List<Reminder>> getAll() => _datasource.getAll();

  @override
  Future<Reminder> create(Reminder reminder) async {
    await _datasource.insert(ReminderModel.fromEntity(reminder));
    return reminder;
  }

  @override
  Future<void> delete(String id) => _datasource.delete(id);

  @override
  Future<void> toggleComplete(String id) async {
    final all = await _datasource.getAll();
    final r = all.firstWhere((e) => e.id == id);
    await _datasource.update(ReminderModel.fromEntity(r.copyWith(isCompleted: !r.isCompleted)));
  }
}
