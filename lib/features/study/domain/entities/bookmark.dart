/// Represents a bookmark within a study document at a specific page.
class Bookmark {
  final String id;
  final String documentId;
  final int pageNumber;
  final String? note;
  final DateTime createdAt;

  const Bookmark({
    required this.id,
    required this.documentId,
    required this.pageNumber,
    this.note,
    required this.createdAt,
  });

  Bookmark copyWith({
    String? id,
    String? documentId,
    int? pageNumber,
    String? note,
    DateTime? createdAt,
  }) {
    return Bookmark(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      pageNumber: pageNumber ?? this.pageNumber,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Bookmark && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
