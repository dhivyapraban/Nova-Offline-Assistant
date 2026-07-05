import '../../domain/entities/timer_entity.dart';

class TimerModel extends TimerEntity {
  const TimerModel({required super.id, super.label, required super.durationSeconds,
    required super.remainingSeconds, super.isRunning, required super.createdAt});

  Map<String, dynamic> toMap() => {
    'id': id, 'label': label, 'duration_seconds': durationSeconds,
    'remaining_seconds': remainingSeconds, 'is_running': isRunning ? 1 : 0,
    'created_at': createdAt.toIso8601String(),
  };

  factory TimerModel.fromMap(Map<String, dynamic> map) => TimerModel(
    id: map['id'] as String, label: map['label'] as String?,
    durationSeconds: map['duration_seconds'] as int,
    remainingSeconds: map['remaining_seconds'] as int,
    isRunning: (map['is_running'] as int) == 1,
    createdAt: DateTime.parse(map['created_at'] as String),
  );

  factory TimerModel.fromEntity(TimerEntity e) => TimerModel(
    id: e.id, label: e.label, durationSeconds: e.durationSeconds,
    remainingSeconds: e.remainingSeconds, isRunning: e.isRunning, createdAt: e.createdAt,
  );
}
