import '../../domain/entities/note.dart';

/// Note model with SQLite serialization
class NoteModel extends Note {
  const NoteModel({
    required super.id,
    required super.title,
    required super.content,
    super.isPinned,
    super.color,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create from SQLite map
  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      isPinned: (map['is_pinned'] as int) == 1,
      color: map['color'] as int?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Create from Note entity
  factory NoteModel.fromEntity(Note note) {
    return NoteModel(
      id: note.id,
      title: note.title,
      content: note.content,
      isPinned: note.isPinned,
      color: note.color,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
    );
  }

  /// Convert to SQLite map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'is_pinned': isPinned ? 1 : 0,
      'color': color,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
