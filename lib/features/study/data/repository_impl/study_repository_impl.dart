import '../../domain/entities/study_document.dart';
import '../../domain/entities/bookmark.dart';
import '../../domain/repositories/study_repository.dart';
import '../datasources/study_local_datasource.dart';

/// Concrete implementation of [StudyRepository] using local datasource.
class StudyRepositoryImpl implements StudyRepository {
  final StudyLocalDatasource _datasource;

  StudyRepositoryImpl(this._datasource);

  @override
  Future<List<StudyDocument>> getDocuments() async {
    return await _datasource.getDocuments();
  }

  @override
  Future<StudyDocument> openDocument(String filePath) async {
    return await _datasource.openDocument(filePath);
  }

  @override
  Future<Bookmark> addBookmark(String documentId, int pageNumber, {String? note}) async {
    return await _datasource.addBookmark(documentId, pageNumber, note: note);
  }

  @override
  Future<void> removeBookmark(String bookmarkId) async {
    return await _datasource.removeBookmark(bookmarkId);
  }

  @override
  Future<List<Bookmark>> getBookmarks(String documentId) async {
    return await _datasource.getBookmarks(documentId);
  }

  @override
  Future<List<StudyDocument>> searchDocuments(String query) async {
    return await _datasource.searchDocuments(query);
  }

  @override
  Future<void> updateLastPage(String documentId, int page) async {
    return await _datasource.updateLastPage(documentId, page);
  }
}
