import '../../domain/entities/todo.dart';

class TodoModel extends Todo {
  const TodoModel({required super.id, required super.title, super.category,
    super.isCompleted, super.priority, required super.createdAt, required super.updatedAt});

  Map<String, dynamic> toMap() => {'id': id, 'title': title, 'category': category,
    'is_completed': isCompleted ? 1 : 0, 'priority': priority,
    'created_at': createdAt.toIso8601String(), 'updated_at': updatedAt.toIso8601String()};

  factory TodoModel.fromMap(Map<String, dynamic> map) => TodoModel(
    id: map['id'] as String, title: map['title'] as String, category: map['category'] as String?,
    isCompleted: (map['is_completed'] as int) == 1, priority: map['priority'] as int? ?? 0,
    createdAt: DateTime.parse(map['created_at'] as String),
    updatedAt: DateTime.parse(map['updated_at'] as String));

  factory TodoModel.fromEntity(Todo e) => TodoModel(id: e.id, title: e.title,
    category: e.category, isCompleted: e.isCompleted, priority: e.priority,
    createdAt: e.createdAt, updatedAt: e.updatedAt);
}
