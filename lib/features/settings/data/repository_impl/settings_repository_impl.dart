import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/entities/app_settings.dart';
import '../models/app_settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  @override
  Future<AppSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final wakeWordValue = prefs.get('wake_word_enabled');
    bool wakeWord = false;
    if (wakeWordValue is bool) {
      wakeWord = wakeWordValue;
    } else if (wakeWordValue is String) {
      wakeWord = wakeWordValue == 'true';
    }

    return AppSettingsModel(
      assistantName: prefs.getString('assistant_name') ?? 'Nova',
      voiceId: prefs.getString('voice_id') ?? 'default',
      listeningMode: prefs.getString('listening_mode') ?? 'push_to_talk',
      modelPath: prefs.getString('model_path'),
      wakeWordEnabled: wakeWord,
    );
  }

  @override
  Future<void> updateSetting(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    if (key == 'wake_word_enabled') {
      await prefs.setBool(key, value == 'true');
    } else {
      await prefs.setString(key, value);
    }
  }

  @override
  Future<void> resetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
