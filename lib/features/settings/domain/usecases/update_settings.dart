import '../repositories/settings_repository.dart';

/// Use case to update a specific setting.
class UpdateSettings {
  final SettingsRepository _repository;

  UpdateSettings(this._repository);

  Future<void> call(String key, String value) {
    return _repository.updateSetting(key, value);
  }
}
