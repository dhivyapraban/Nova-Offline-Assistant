/// Represents a study document (PDF) opened in the study assistant.
class StudyDocument {
  final String id;
  final String title;
  final String filePath;
  final int pageCount;
  final int lastPage;
  final DateTime openedAt;
  final List<int> bookmarkedPages;

  const StudyDocument({
    required this.id,
    required this.title,
    required this.filePath,
    this.pageCount = 0,
    this.lastPage = 0,
    required this.openedAt,
    this.bookmarkedPages = const [],
  });

  StudyDocument copyWith({
    String? id,
    String? title,
    String? filePath,
    int? pageCount,
    int? lastPage,
    DateTime? openedAt,
    List<int>? bookmarkedPages,
  }) {
    return StudyDocument(
      id: id ?? this.id,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      pageCount: pageCount ?? this.pageCount,
      lastPage: lastPage ?? this.lastPage,
      openedAt: openedAt ?? this.openedAt,
      bookmarkedPages: bookmarkedPages ?? List.from(this.bookmarkedPages),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudyDocument &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
