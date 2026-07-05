import '../entities/study_document.dart';
import '../repositories/study_repository.dart';

/// Opens a document from a file path and registers it.
class OpenDocument {
  final StudyRepository _repository;

  OpenDocument(this._repository);

  Future<StudyDocument> call(String filePath) async {
    return await _repository.openDocument(filePath);
  }
}
