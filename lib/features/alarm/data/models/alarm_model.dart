import 'dart:convert';

import '../../domain/entities/alarm.dart';

/// Data model for Alarm entity with SQLite serialization
class AlarmModel extends Alarm {
  const AlarmModel({
    required super.id,
    super.label,
    required super.hour,
    required super.minute,
    super.isEnabled,
    super.repeatDays,
    required super.createdAt,
  });

  /// Create AlarmModel from a Map (SQLite row)
  factory AlarmModel.fromMap(Map<String, dynamic> map) {
    return AlarmModel(
      id: map['id'] as String,
      label: map['label'] as String?,
      hour: map['hour'] as int,
      minute: map['minute'] as int,
      isEnabled: (map['is_enabled'] as int) == 1,
      repeatDays: map['repeat_days'] != null
          ? (jsonDecode(map['repeat_days'] as String) as List<dynamic>)
              .cast<int>()
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Create AlarmModel from an Alarm entity
  factory AlarmModel.fromEntity(Alarm alarm) {
    return AlarmModel(
      id: alarm.id,
      label: alarm.label,
      hour: alarm.hour,
      minute: alarm.minute,
      isEnabled: alarm.isEnabled,
      repeatDays: alarm.repeatDays,
      createdAt: alarm.createdAt,
    );
  }

  /// Convert to Map for SQLite insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'hour': hour,
      'minute': minute,
      'is_enabled': isEnabled ? 1 : 0,
      'repeat_days': repeatDays != null ? jsonEncode(repeatDays) : null,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
