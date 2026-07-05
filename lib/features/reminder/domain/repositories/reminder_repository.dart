import '../entities/reminder.dart';

abstract class ReminderRepository {
  Future<List<Reminder>> getAll();
  Future<Reminder> create(Reminder reminder);
  Future<void> delete(String id);
  Future<void> toggleComplete(String id);
}
