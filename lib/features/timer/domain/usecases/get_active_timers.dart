import '../repositories/timer_repository.dart';
import '../entities/timer_entity.dart';

class GetActiveTimers {
  final TimerRepository repository;
  GetActiveTimers(this.repository);
  Future<List<TimerEntity>> call() => repository.getAll();
}
