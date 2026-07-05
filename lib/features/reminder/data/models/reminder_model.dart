import '../../domain/entities/reminder.dart';

class ReminderModel extends Reminder {
  const ReminderModel({required super.id, required super.title, super.description,
    required super.remindAt, super.isCompleted, required super.createdAt});

  Map<String, dynamic> toMap() => {'id': id, 'title': title, 'description': description,
    'remind_at': remindAt.toIso8601String(), 'is_completed': isCompleted ? 1 : 0,
    'created_at': createdAt.toIso8601String()};

  factory ReminderModel.fromMap(Map<String, dynamic> map) => ReminderModel(
    id: map['id'] as String, title: map['title'] as String,
    description: map['description'] as String?,
    remindAt: DateTime.parse(map['remind_at'] as String),
    isCompleted: (map['is_completed'] as int) == 1,
    createdAt: DateTime.parse(map['created_at'] as String));

  factory ReminderModel.fromEntity(Reminder e) => ReminderModel(
    id: e.id, title: e.title, description: e.description,
    remindAt: e.remindAt, isCompleted: e.isCompleted, createdAt: e.createdAt);
}
