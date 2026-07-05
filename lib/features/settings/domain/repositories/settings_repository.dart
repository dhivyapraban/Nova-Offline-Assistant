import '../entities/app_settings.dart';

/// Abstract repository for app settings operations.
abstract class SettingsRepository {
  /// Retrieves the current app settings.
  Future<AppSettings> getSettings();

  /// Updates a single setting by key-value pair.
  Future<void> updateSetting(String key, String value);

  /// Resets all settings to their default values.
  Future<void> resetSettings();
}
