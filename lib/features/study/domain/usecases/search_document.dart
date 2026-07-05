import '../entities/study_document.dart';
import '../repositories/study_repository.dart';

/// Searches study documents by title.
class SearchDocument {
  final StudyRepository _repository;

  SearchDocument(this._repository);

  Future<List<StudyDocument>> call(String query) async {
    return await _repository.searchDocuments(query);
  }
}
