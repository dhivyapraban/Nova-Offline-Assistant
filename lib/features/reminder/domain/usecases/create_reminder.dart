import '../repositories/reminder_repository.dart';
import '../entities/reminder.dart';

class CreateReminder {
  final ReminderRepository repository;
  CreateReminder(this.repository);
  Future<Reminder> call(Reminder reminder) => repository.create(reminder);
}
