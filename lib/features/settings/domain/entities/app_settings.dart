/// Represents the application settings.
class AppSettings {
  final String assistantName;
  final String voiceId;
  final String listeningMode;
  final String? modelPath;
  final bool wakeWordEnabled;

  const AppSettings({
    this.assistantName = 'Nova',
    this.voiceId = 'default',
    this.listeningMode = 'push_to_talk',
    this.modelPath,
    this.wakeWordEnabled = false,
  });

  AppSettings copyWith({
    String? assistantName,
    String? voiceId,
    String? listeningMode,
    String? modelPath,
    bool? wakeWordEnabled,
  }) {
    return AppSettings(
      assistantName: assistantName ?? this.assistantName,
      voiceId: voiceId ?? this.voiceId,
      listeningMode: listeningMode ?? this.listeningMode,
      modelPath: modelPath ?? this.modelPath,
      wakeWordEnabled: wakeWordEnabled ?? this.wakeWordEnabled,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          runtimeType == other.runtimeType &&
          assistantName == other.assistantName &&
          voiceId == other.voiceId &&
          listeningMode == other.listeningMode &&
          modelPath == other.modelPath &&
          wakeWordEnabled == other.wakeWordEnabled;

  @override
  int get hashCode => Object.hash(
        assistantName,
        voiceId,
        listeningMode,
        modelPath,
        wakeWordEnabled,
      );

  @override
  String toString() =>
      'AppSettings(assistantName: $assistantName, voiceId: $voiceId, listeningMode: $listeningMode, modelPath: $modelPath, wakeWordEnabled: $wakeWordEnabled)';
}
