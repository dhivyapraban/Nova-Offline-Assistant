import '../entities/installed_app.dart';

/// Abstract repository for app launcher operations.
abstract class LauncherRepository {
  /// Retrieves all installed applications on the device.
  Future<List<InstalledApp>> getInstalledApps();

  /// Searches installed apps by name query.
  Future<List<InstalledApp>> searchApps(String query);

  /// Launches an app by its package name.
  Future<bool> launchApp(String packageName);
}
