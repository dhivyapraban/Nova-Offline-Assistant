import '../entities/file_item.dart';

/// Abstract contract for file data operations.
abstract class FileRepository {
  Future<List<FileItem>> searchFiles(String query);
  Future<List<FileItem>> getRecentFiles();
  Future<List<FileItem>> getAllFiles({FileType? filterType});
  Future<void> toggleFavorite(String fileId);
  Future<List<FileItem>> getFavorites();
  Future<void> openFile(FileItem file);
}
