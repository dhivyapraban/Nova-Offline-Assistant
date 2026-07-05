class Todo {
  final String id;
  final String title;
  final String? category;
  final bool isCompleted;
  final int priority; // 0=low, 1=medium, 2=high
  final DateTime createdAt;
  final DateTime updatedAt;

  const Todo({required this.id, required this.title, this.category,
    this.isCompleted = false, this.priority = 0, required this.createdAt, required this.updatedAt});

  Todo copyWith({String? id, String? title, String? category,
    bool? isCompleted, int? priority, DateTime? createdAt, DateTime? updatedAt}) {
    return Todo(id: id ?? this.id, title: title ?? this.title,
      category: category ?? this.category, isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority, createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt);
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is Todo && id == other.id;
  @override
  int get hashCode => id.hashCode;
}
