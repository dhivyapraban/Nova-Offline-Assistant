import '../entities/installed_app.dart';
import '../repositories/launcher_repository.dart';

/// Use case to retrieve all installed applications.
class GetInstalledApps {
  final LauncherRepository _repository;

  GetInstalledApps(this._repository);

  Future<List<InstalledApp>> call() {
    return _repository.getInstalledApps();
  }
}
