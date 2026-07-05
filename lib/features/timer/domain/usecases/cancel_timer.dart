import '../repositories/timer_repository.dart';

class CancelTimer {
  final TimerRepository repository;
  CancelTimer(this.repository);
  Future<void> call(String id) => repository.delete(id);
}
