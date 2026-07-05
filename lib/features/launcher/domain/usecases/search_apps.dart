import '../entities/installed_app.dart';
import '../repositories/launcher_repository.dart';

/// Use case to search installed applications by name.
class SearchApps {
  final LauncherRepository _repository;

  SearchApps(this._repository);

  Future<List<InstalledApp>> call(String query) {
    return _repository.searchApps(query);
  }
}
