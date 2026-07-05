import '../entities/file_item.dart';
import '../repositories/file_repository.dart';

/// Retrieves recently accessed files.
class GetRecentFiles {
  final FileRepository _repository;

  GetRecentFiles(this._repository);

  Future<List<FileItem>> call() async {
    return await _repository.getRecentFiles();
  }
}
