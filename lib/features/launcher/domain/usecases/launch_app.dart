import '../repositories/launcher_repository.dart';

/// Use case to launch an application by package name.
class LaunchApp {
  final LauncherRepository _repository;

  LaunchApp(this._repository);

  Future<bool> call(String packageName) {
    return _repository.launchApp(packageName);
  }
}
