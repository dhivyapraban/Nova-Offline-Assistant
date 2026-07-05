import '../../domain/entities/installed_app.dart';

/// Data model for InstalledApp with serialization support.
class InstalledAppModel extends InstalledApp {
  const InstalledAppModel({
    required super.packageName,
    required super.appName,
    super.versionName,
  });

  /// Creates an InstalledAppModel from a map (platform channel response).
  factory InstalledAppModel.fromMap(Map<String, dynamic> map) {
    return InstalledAppModel(
      packageName: map['packageName'] as String? ?? '',
      appName: map['appName'] as String? ?? '',
      versionName: map['versionName'] as String?,
    );
  }

  /// Converts the model to a map.
  Map<String, dynamic> toMap() {
    return {
      'packageName': packageName,
      'appName': appName,
      'versionName': versionName,
    };
  }

  /// Creates an InstalledAppModel from an InstalledApp entity.
  factory InstalledAppModel.fromEntity(InstalledApp app) {
    return InstalledAppModel(
      packageName: app.packageName,
      appName: app.appName,
      versionName: app.versionName,
    );
  }
}
