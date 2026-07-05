import '../repositories/reminder_repository.dart';
import '../entities/reminder.dart';

class GetReminders {
  final ReminderRepository repository;
  GetReminders(this.repository);
  Future<List<Reminder>> call() => repository.getAll();
}
