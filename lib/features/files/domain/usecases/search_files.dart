import '../entities/file_item.dart';
import '../repositories/file_repository.dart';

/// Searches for files matching a query string.
class SearchFiles {
  final FileRepository _repository;

  SearchFiles(this._repository);

  Future<List<FileItem>> call(String query) async {
    return await _repository.searchFiles(query);
  }
}
