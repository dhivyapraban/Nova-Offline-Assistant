import '../repositories/file_repository.dart';

/// Toggles the favorite status of a file.
class ToggleFavorite {
  final FileRepository _repository;

  ToggleFavorite(this._repository);

  Future<void> call(String fileId) async {
    return await _repository.toggleFavorite(fileId);
  }
}
