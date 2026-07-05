import '../repositories/timer_repository.dart';
import '../entities/timer_entity.dart';

class CreateTimer {
  final TimerRepository repository;
  CreateTimer(this.repository);
  Future<TimerEntity> call(TimerEntity timer) => repository.create(timer);
}
