import '../repositories/alarm_repository.dart';

/// Use case to cancel (delete) an alarm
class CancelAlarm {
  final AlarmRepository _repository;

  CancelAlarm(this._repository);

  Future<void> call(String id) async {
    await _repository.delete(id);
  }
}
