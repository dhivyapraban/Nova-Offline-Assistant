import '../../domain/entities/file_item.dart';
import '../../domain/repositories/file_repository.dart';
import '../datasources/file_local_datasource.dart';

/// Concrete implementation of [FileRepository] using local datasource.
class FileRepositoryImpl implements FileRepository {
  final FileLocalDatasource _datasource;

  FileRepositoryImpl(this._datasource);

  @override
  Future<List<FileItem>> searchFiles(String query) async {
    return await _datasource.searchFiles(query);
  }

  @override
  Future<List<FileItem>> getRecentFiles() async {
    return await _datasource.getRecentFiles();
  }

  @override
  Future<List<FileItem>> getAllFiles({FileType? filterType}) async {
    return await _datasource.getAllFiles(filterType: filterType);
  }

  @override
  Future<void> toggleFavorite(String fileId) async {
    return await _datasource.toggleFavorite(fileId);
  }

  @override
  Future<List<FileItem>> getFavorites() async {
    return await _datasource.getFavorites();
  }

  @override
  Future<void> openFile(FileItem file) async {
    return await _datasource.openFile(file.path);
  }
}
