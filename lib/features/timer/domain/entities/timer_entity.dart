class TimerEntity {
  final String id;
  final String? label;
  final int durationSeconds;
  final int remainingSeconds;
  final bool isRunning;
  final DateTime createdAt;

  const TimerEntity({
    required this.id,
    this.label,
    required this.durationSeconds,
    required this.remainingSeconds,
    this.isRunning = false,
    required this.createdAt,
  });

  TimerEntity copyWith({
    String? id, String? label, int? durationSeconds,
    int? remainingSeconds, bool? isRunning, DateTime? createdAt,
  }) {
    return TimerEntity(
      id: id ?? this.id, label: label ?? this.label,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is TimerEntity && id == other.id;
  @override
  int get hashCode => id.hashCode;
}
