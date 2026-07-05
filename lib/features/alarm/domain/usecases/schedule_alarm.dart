import '../entities/alarm.dart';
import '../repositories/alarm_repository.dart';

/// Use case to schedule (create) a new alarm
class ScheduleAlarm {
  final AlarmRepository _repository;

  ScheduleAlarm(this._repository);

  Future<Alarm> call(Alarm alarm) async {
    return await _repository.create(alarm);
  }
}
