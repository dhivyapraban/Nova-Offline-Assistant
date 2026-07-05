import '../entities/bookmark.dart';
import '../repositories/study_repository.dart';

/// Adds a bookmark to a document at a given page.
class AddBookmark {
  final StudyRepository _repository;

  AddBookmark(this._repository);

  Future<Bookmark> call(String documentId, int pageNumber, {String? note}) async {
    return await _repository.addBookmark(documentId, pageNumber, note: note);
  }
}
