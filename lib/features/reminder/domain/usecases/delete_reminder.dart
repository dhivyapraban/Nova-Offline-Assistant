import '../repositories/reminder_repository.dart';

class DeleteReminder {
  final ReminderRepository repository;
  DeleteReminder(this.repository);
  Future<void> call(String id) => repository.delete(id);
}
