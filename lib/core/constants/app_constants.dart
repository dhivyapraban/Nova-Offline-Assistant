/// App-wide constants for Nova Assistant
class AppConstants {
  AppConstants._();

  static const String appName = 'Nova Assistant';
  static const String defaultAssistantName = 'Nova';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.nova.nova_assistant';

  // Database
  static const String dbName = 'nova_assistant.db';
  static const int dbVersion = 1;

  // Listening modes
  static const String pushToTalk = 'push_to_talk';
  static const String continuous = 'continuous';

  // AI Intents
  static const String intentCreateNote = 'create_note';
  static const String intentSetTimer = 'set_timer';
  static const String intentSetAlarm = 'set_alarm';
  static const String intentSetReminder = 'set_reminder';
  static const String intentAddTodo = 'add_todo';
  static const String intentPlayMusic = 'play_music';
  static const String intentSearchFiles = 'search_files';
  static const String intentOpenApp = 'open_app';
  static const String intentSystemControl = 'system_control';
  static const String intentGreeting = 'greeting';
  static const String intentGeneral = 'general';
  static const String intentUnknown = 'unknown';

  // Settings keys
  static const String settingThemeMode = 'theme_mode';
  static const String settingAssistantName = 'assistant_name';
  static const String settingVoiceId = 'voice_id';
  static const String settingListeningMode = 'listening_mode';
  static const String settingModelPath = 'model_path';
  static const String settingWakeWord = 'wake_word_enabled';

  // Animation durations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);
  static const Duration animVerySlow = Duration(milliseconds: 800);

  // Layout
  static const double borderRadius = 16.0;
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusLarge = 24.0;
  static const double cardElevation = 0.0;
  static const double padding = 16.0;
  static const double paddingSmall = 8.0;
  static const double paddingLarge = 24.0;
}
