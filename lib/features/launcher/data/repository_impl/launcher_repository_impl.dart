import '../../domain/entities/installed_app.dart';
import '../../domain/repositories/launcher_repository.dart';
import '../datasources/launcher_datasource.dart';

/// Concrete implementation of [LauncherRepository].
class LauncherRepositoryImpl implements LauncherRepository {
  final LauncherDatasource _datasource;

  LauncherRepositoryImpl(this._datasource);

  List<InstalledApp>? _cachedApps;

  @override
  Future<List<InstalledApp>> getInstalledApps() async {
    if (_cachedApps != null) return _cachedApps!;

    final apps = await _datasource.getInstalledApps();
    // Sort alphabetically by app name
    apps.sort((a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));
    _cachedApps = apps;
    return apps;
  }

  @override
  Future<List<InstalledApp>> searchApps(String query) async {
    final apps = await getInstalledApps();
    if (query.trim().isEmpty) return apps;

    final lowerQuery = query.toLowerCase();
    return apps
        .where((app) =>
            app.appName.toLowerCase().contains(lowerQuery) ||
            app.packageName.toLowerCase().contains(lowerQuery))
        .toList();
  }

  @override
  Future<bool> launchApp(String packageName) async {
    return _datasource.launchApp(packageName);
  }

  /// Clears the cached app list, forcing a refresh on next fetch.
  void clearCache() {
    _cachedApps = null;
  }
}
