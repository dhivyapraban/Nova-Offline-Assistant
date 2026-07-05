import '../entities/timer_entity.dart';

abstract class TimerRepository {
  Future<List<TimerEntity>> getAll();
  Future<TimerEntity> create(TimerEntity timer);
  Future<void> update(TimerEntity timer);
  Future<void> delete(String id);
  Future<void> deleteAll();
}
