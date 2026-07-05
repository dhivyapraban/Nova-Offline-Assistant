import '../entities/study_document.dart';
import '../entities/bookmark.dart';

/// Abstract contract for study data operations.
abstract class StudyRepository {
  Future<List<StudyDocument>> getDocuments();
  Future<StudyDocument> openDocument(String filePath);
  Future<Bookmark> addBookmark(String documentId, int pageNumber, {String? note});
  Future<void> removeBookmark(String bookmarkId);
  Future<List<Bookmark>> getBookmarks(String documentId);
  Future<List<StudyDocument>> searchDocuments(String query);
  Future<void> updateLastPage(String documentId, int page);
}
