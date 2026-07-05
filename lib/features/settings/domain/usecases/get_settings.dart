import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

/// Use case to retrieve the current app settings.
class GetSettings {
  final SettingsRepository _repository;

  GetSettings(this._repository);

  Future<AppSettings> call() {
    return _repository.getSettings();
  }
}
