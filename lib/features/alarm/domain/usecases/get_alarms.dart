import '../entities/alarm.dart';
import '../repositories/alarm_repository.dart';

/// Use case to fetch all alarms
class GetAlarms {
  final AlarmRepository _repository;

  GetAlarms(this._repository);

  Future<List<Alarm>> call() async {
    return await _repository.getAll();
  }
}
