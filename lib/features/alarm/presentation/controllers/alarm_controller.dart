import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/alarm.dart';
import '../../domain/repositories/alarm_repository.dart';
import '../../data/datasources/alarm_local_datasource.dart';
import '../../data/repository_impl/alarm_repository_impl.dart';

/// Provider for the alarm repository
final alarmRepositoryProvider = Provider<AlarmRepository>((ref) {
  return AlarmRepositoryImpl(AlarmLocalDatasource());
});

/// StateNotifier that manages the list of alarms
class AlarmController extends StateNotifier<AsyncValue<List<Alarm>>> {
  final AlarmRepository _repository;
  static const _uuid = Uuid();

  AlarmController(this._repository) : super(const AsyncValue.loading()) {
    loadAlarms();
  }

  /// Load all alarms from the repository
  Future<void> loadAlarms() async {
    try {
      state = const AsyncValue.loading();
      final alarms = await _repository.getAll();
      state = AsyncValue.data(alarms);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Create a new alarm
  Future<void> createAlarm({
    String? label,
    required int hour,
    required int minute,
    List<int>? repeatDays,
  }) async {
    try {
      final alarm = Alarm(
        id: _uuid.v4(),
        label: label,
        hour: hour,
        minute: minute,
        isEnabled: true,
        repeatDays: repeatDays,
        createdAt: DateTime.now(),
      );
      await _repository.create(alarm);
      await loadAlarms();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Update an existing alarm
  Future<void> updateAlarm(Alarm alarm) async {
    try {
      await _repository.update(alarm);
      await loadAlarms();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Delete an alarm by ID
  Future<void> deleteAlarm(String id) async {
    try {
      await _repository.delete(id);
      // Optimistically remove from state
      final current = state.valueOrNull ?? [];
      state = AsyncValue.data(
        current.where((a) => a.id != id).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Toggle alarm enabled/disabled
  Future<void> toggleAlarm(String id, bool isEnabled) async {
    try {
      await _repository.toggleEnabled(id, isEnabled);
      // Optimistically update state
      final current = state.valueOrNull ?? [];
      state = AsyncValue.data(
        current
            .map((a) => a.id == id ? a.copyWith(isEnabled: isEnabled) : a)
            .toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider for the alarm controller
final alarmControllerProvider =
    StateNotifierProvider<AlarmController, AsyncValue<List<Alarm>>>((ref) {
  return AlarmController(ref.read(alarmRepositoryProvider));
});
