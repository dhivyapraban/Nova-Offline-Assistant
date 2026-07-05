import '../entities/alarm.dart';

/// Abstract repository interface for alarm operations
abstract class AlarmRepository {
  Future<List<Alarm>> getAll();
  Future<Alarm> create(Alarm alarm);
  Future<void> update(Alarm alarm);
  Future<void> delete(String id);
  Future<void> toggleEnabled(String id, bool isEnabled);
}
