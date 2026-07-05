import '../../domain/entities/study_document.dart';
import '../../domain/entities/bookmark.dart';

/// Data model for StudyDocument with SQLite serialization.
class StudyDocumentModel extends StudyDocument {
  const StudyDocumentModel({
    required super.id,
    required super.title,
    required super.filePath,
    super.pageCount,
    super.lastPage,
    required super.openedAt,
    super.bookmarkedPages,
  });

  factory StudyDocumentModel.fromEntity(StudyDocument doc) {
    return StudyDocumentModel(
      id: doc.id,
      title: doc.title,
      filePath: doc.filePath,
      pageCount: doc.pageCount,
      lastPage: doc.lastPage,
      openedAt: doc.openedAt,
      bookmarkedPages: List.from(doc.bookmarkedPages),
    );
  }

  factory StudyDocumentModel.fromMap(Map<String, dynamic> map) {
    final pagesRaw = map['bookmarked_pages'] as String? ?? '';
    return StudyDocumentModel(
      id: map['id'] as String,
      title: map['title'] as String,
      filePath: map['file_path'] as String,
      pageCount: map['page_count'] as int? ?? 0,
      lastPage: map['last_page'] as int? ?? 0,
      openedAt: DateTime.parse(map['opened_at'] as String),
      bookmarkedPages: pagesRaw.isEmpty
          ? []
          : pagesRaw.split(',').map((e) => int.parse(e.trim())).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'file_path': filePath,
      'page_count': pageCount,
      'last_page': lastPage,
      'opened_at': openedAt.toIso8601String(),
      'bookmarked_pages': bookmarkedPages.join(','),
    };
  }
}

/// Data model for Bookmark with SQLite serialization.
class BookmarkModel extends Bookmark {
  const BookmarkModel({
    required super.id,
    required super.documentId,
    required super.pageNumber,
    super.note,
    required super.createdAt,
  });

  factory BookmarkModel.fromEntity(Bookmark bookmark) {
    return BookmarkModel(
      id: bookmark.id,
      documentId: bookmark.documentId,
      pageNumber: bookmark.pageNumber,
      note: bookmark.note,
      createdAt: bookmark.createdAt,
    );
  }

  factory BookmarkModel.fromMap(Map<String, dynamic> map) {
    return BookmarkModel(
      id: map['id'] as String,
      documentId: map['document_id'] as String,
      pageNumber: map['page_number'] as int,
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'document_id': documentId,
      'page_number': pageNumber,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
