/// Represents an installed application on the device.
class InstalledApp {
  final String packageName;
  final String appName;
  final String? versionName;

  const InstalledApp({
    required this.packageName,
    required this.appName,
    this.versionName,
  });

  InstalledApp copyWith({
    String? packageName,
    String? appName,
    String? versionName,
  }) {
    return InstalledApp(
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      versionName: versionName ?? this.versionName,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InstalledApp &&
          runtimeType == other.runtimeType &&
          packageName == other.packageName;

  @override
  int get hashCode => packageName.hashCode;

  @override
  String toString() => 'InstalledApp(packageName: $packageName, appName: $appName)';
}
