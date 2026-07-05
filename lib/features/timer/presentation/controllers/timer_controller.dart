import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/timer_entity.dart';
import '../../domain/repositories/timer_repository.dart';
import '../../data/datasources/timer_local_datasource.dart';
import '../../data/repository_impl/timer_repository_impl.dart';

final timerRepositoryProvider = Provider<TimerRepository>((ref) {
  return TimerRepositoryImpl(TimerLocalDatasource());
});

final timerControllerProvider =
    StateNotifierProvider<TimerController, List<TimerEntity>>((ref) {
  return TimerController(ref.read(timerRepositoryProvider));
});

class TimerController extends StateNotifier<List<TimerEntity>> {
  final TimerRepository _repository;
  final Map<String, Timer> _activeTimers = {};
  static const _uuid = Uuid();

  TimerController(this._repository) : super([]) {
    _init();
  }

  /// On startup: clear any stale DB entries (timers don't survive restarts).
  /// Timers are purely in-memory — DB is only used to restore label+duration.
  Future<void> _init() async {
    try {
      await _repository.deleteAll();
    } catch (_) {
      // ignore — table may not exist yet on first run
    }
    state = [];
  }

  Future<void> addTimer({required int seconds, String? label}) async {
    final entity = TimerEntity(
      id: _uuid.v4(),
      label: label,
      durationSeconds: seconds,
      remainingSeconds: seconds,
      isRunning: true,
      createdAt: DateTime.now(),
    );
    try {
      await _repository.create(entity);
    } catch (_) {}
    state = [...state, entity];
    _startCountdown(entity.id);
  }

  void _startCountdown(String id) {
    _activeTimers[id]?.cancel();
    _activeTimers[id] = Timer.periodic(const Duration(seconds: 1), (ticker) {
      if (!mounted) {
        ticker.cancel();
        return;
      }
      final index = state.indexWhere((t) => t.id == id);
      if (index == -1) {
        ticker.cancel();
        return;
      }
      final current = state[index];
      if (!current.isRunning) {
        ticker.cancel();
        return;
      }
      if (current.remainingSeconds <= 0) {
        ticker.cancel();
        _activeTimers.remove(id);
        return;
      }
      final updated = current.copyWith(
        remainingSeconds: current.remainingSeconds - 1,
      );
      final newState = [...state];
      newState[index] = updated;
      state = newState;

      if (updated.remainingSeconds <= 0) {
        ticker.cancel();
        _activeTimers.remove(id);
      }
    });
  }

  void togglePause(String id) {
    final index = state.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final current = state[index];
    final updated = current.copyWith(isRunning: !current.isRunning);
    final newState = [...state];
    newState[index] = updated;
    state = newState;

    if (updated.isRunning) {
      _startCountdown(id);
    } else {
      _activeTimers[id]?.cancel();
      _activeTimers.remove(id);
    }
  }

  Future<void> removeTimer(String id) async {
    _activeTimers[id]?.cancel();
    _activeTimers.remove(id);
    try {
      await _repository.delete(id);
    } catch (_) {}
    state = state.where((t) => t.id != id).toList();
  }

  @override
  void dispose() {
    for (final t in _activeTimers.values) {
      t.cancel();
    }
    super.dispose();
  }
}
