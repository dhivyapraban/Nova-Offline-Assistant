class Reminder {
  final String id;
  final String title;
  final String? description;
  final DateTime remindAt;
  final bool isCompleted;
  final DateTime createdAt;

  const Reminder({required this.id, required this.title, this.description,
    required this.remindAt, this.isCompleted = false, required this.createdAt});

  Reminder copyWith({String? id, String? title, String? description,
    DateTime? remindAt, bool? isCompleted, DateTime? createdAt}) {
    return Reminder(id: id ?? this.id, title: title ?? this.title,
      description: description ?? this.description, remindAt: remindAt ?? this.remindAt,
      isCompleted: isCompleted ?? this.isCompleted, createdAt: createdAt ?? this.createdAt);
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is Reminder && id == other.id;
  @override
  int get hashCode => id.hashCode;
}
