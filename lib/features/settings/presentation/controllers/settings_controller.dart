import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../data/repository_impl/settings_repository_impl.dart';
import '../../../voice/presentation/controllers/voice_controller.dart';
import '../../../../core/services/platform_channel_service.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl();
});

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, AsyncValue<AppSettings>>((ref) {
  return SettingsController(ref.read(settingsRepositoryProvider), ref);
});

class SettingsController extends StateNotifier<AsyncValue<AppSettings>> {
  final SettingsRepository _repository;
  final Ref _ref;

  SettingsController(this._repository, this._ref)
      : super(const AsyncValue.loading()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      final settings = await _repository.getSettings();
      state = AsyncValue.data(settings);
      
      // Auto-start native background listener on startup if enabled
      if (settings.wakeWordEnabled) {
        PlatformChannelService.instance.startWakeWordService().catchError((_) {});
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateAssistantName(String name) async {
    final current = state.valueOrNull ?? const AppSettings();
    state = AsyncValue.data(current.copyWith(assistantName: name));
    await _repository.updateSetting('assistant_name', name);
  }

  Future<void> updateListeningMode(String mode) async {
    final current = state.valueOrNull ?? const AppSettings();
    state = AsyncValue.data(current.copyWith(listeningMode: mode));
    await _repository.updateSetting('listening_mode', mode);

    // Immediately apply to VoiceController so it takes effect without restart
    try {
      final listenMode = mode == 'continuous'
          ? ListeningMode.continuous
          : ListeningMode.pushToTalk;
      _ref.read(voiceControllerProvider.notifier).setMode(listenMode);
    } catch (_) {}
  }

  Future<void> updateModelPath(String path) async {
    final current = state.valueOrNull ?? const AppSettings();
    state = AsyncValue.data(current.copyWith(modelPath: path));
    await _repository.updateSetting('model_path', path);
  }

  Future<void> toggleWakeWord(bool enabled) async {
    final current = state.valueOrNull ?? const AppSettings();
    state = AsyncValue.data(current.copyWith(wakeWordEnabled: enabled));
    await _repository.updateSetting('wake_word_enabled', enabled.toString());
    
    try {
      if (enabled) {
        await PlatformChannelService.instance.startWakeWordService();
      } else {
        await PlatformChannelService.instance.stopWakeWordService();
      }
    } catch (_) {}
  }

  Future<void> resetSettings() async {
    state = const AsyncValue.loading();
    await _repository.resetSettings();
    await loadSettings();
  }
}
