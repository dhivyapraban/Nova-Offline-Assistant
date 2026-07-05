import '../../domain/entities/app_settings.dart';

/// Data model for AppSettings with serialization support.
class AppSettingsModel extends AppSettings {
  const AppSettingsModel({
    required super.assistantName,
    required super.voiceId,
    required super.listeningMode,
    super.modelPath,
    required super.wakeWordEnabled,
  });

  /// Creates an AppSettingsModel from a map of key-value pairs
  /// (as stored in the settings SQLite table).
  factory AppSettingsModel.fromMap(Map<String, String> map) {
    return AppSettingsModel(
      assistantName: map['assistant_name'] ?? 'Nova',
      voiceId: map['voice_id'] ?? 'default',
      listeningMode: map['listening_mode'] ?? 'push_to_talk',
      modelPath: map['model_path'],
      wakeWordEnabled: map['wake_word_enabled'] == 'true',
    );
  }

  /// Converts the model to a map of key-value pairs for storage.
  Map<String, String> toMap() {
    return {
      'assistant_name': assistantName,
      'voice_id': voiceId,
      'listening_mode': listeningMode,
      if (modelPath != null) 'model_path': modelPath!,
      'wake_word_enabled': wakeWordEnabled.toString(),
    };
  }

  /// Creates an AppSettingsModel from an AppSettings entity.
  factory AppSettingsModel.fromEntity(AppSettings settings) {
    return AppSettingsModel(
      assistantName: settings.assistantName,
      voiceId: settings.voiceId,
      listeningMode: settings.listeningMode,
      modelPath: settings.modelPath,
      wakeWordEnabled: settings.wakeWordEnabled,
    );
  }

  /// Default settings instance.
  static const AppSettingsModel defaults = AppSettingsModel(
    assistantName: 'Nova',
    voiceId: 'default',
    listeningMode: 'push_to_talk',
    wakeWordEnabled: false,
  );
}
