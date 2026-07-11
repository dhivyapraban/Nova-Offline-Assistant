import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/conversation_message.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../../data/datasources/conversation_local_datasource.dart';
import '../../data/repository_impl/conversation_repository_impl.dart';
import '../../../ai_engine/domain/repositories/ai_repository.dart';
import '../../../ai_engine/domain/entities/intent.dart';
// Use the shared singleton provider from ai_engine_controller
import '../../../ai_engine/presentation/controllers/ai_engine_controller.dart';
import '../../../../core/services/platform_channel_service.dart';
import '../../../launcher/domain/entities/installed_app.dart';
import '../../../launcher/presentation/pages/app_launcher_page.dart';
import '../../../../core/services/tts_service.dart';

// Global callback to execute page navigation without circular dependencies
void Function(String)? onAssistantNavigate;

final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  return ConversationRepositoryImpl(ConversationLocalDatasource());
});

final conversationControllerProvider =
    StateNotifierProvider<ConversationController, ConversationState>((ref) {
  return ConversationController(
    ref.read(conversationRepositoryProvider),
    ref.read(aiRepositoryProvider),
    ref,
  );
});

class ConversationState {
  final List<ConversationMessage> messages;
  final bool isLoading;
  final bool isProcessing;
  final String? error;

  const ConversationState({
    this.messages = const [],
    this.isLoading = false,
    this.isProcessing = false,
    this.error,
  });

  ConversationState copyWith({
    List<ConversationMessage>? messages,
    bool? isLoading,
    bool? isProcessing,
    String? error,
  }) {
    return ConversationState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
    );
  }
}

class ConversationController extends StateNotifier<ConversationState> {
  final ConversationRepository _repository;
  final AIRepository _aiRepository;
  final Ref _ref;
  static const _uuid = Uuid();

  ConversationController(this._repository, this._aiRepository, this._ref)
      : super(const ConversationState(isLoading: true)) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final messages = await _repository.getRecentMessages(limit: 50);
      state = state.copyWith(messages: messages, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _executeIntentAction(Intent intent, String rawText) async {
    if (intent.type == IntentType.setTimer) {
      int seconds = 300; // default 5 minutes
      final actionData = intent.parameters;
      final val = actionData['duration_value'] ?? actionData['number'];
      if (val is int) {
        final unit = actionData['duration_unit'] as String?;
        if (unit == 'second' || unit == 'seconds') {
          seconds = val;
        } else if (unit == 'hour' || unit == 'hours') {
          seconds = val * 3600;
        } else {
          seconds = val * 60; // default to minutes
        }
      }
      try {
        await PlatformChannelService.instance.openTimer(seconds);
      } catch (_) {}
    }

    if (intent.type == IntentType.openApp) {
      final actionData = intent.parameters;
      String? appName = actionData['app_name'] as String?;
      appName ??= actionData['text'] as String?;

      if (appName != null && appName.isNotEmpty) {
        try {
          final launcherState = _ref.read(launcherControllerProvider);
          final lowerName = appName.toLowerCase();
          final matchedApp = launcherState.apps.firstWhere(
            (app) => app.appName.toLowerCase().contains(lowerName) ||
                     app.packageName.toLowerCase().contains(lowerName),
            orElse: () => const InstalledApp(packageName: '', appName: ''),
          );

          if (matchedApp.packageName.isNotEmpty) {
            await _ref.read(launcherControllerProvider.notifier).launchApp(matchedApp.packageName);
          }
        } catch (_) {}
      }
    }

    if (intent.type == IntentType.createNote) {
      final actionData = intent.parameters;
      final noteText = actionData['text'] as String?;
      try {
        await PlatformChannelService.instance.openNotes(text: noteText);
      } catch (_) {}
    }

    if (intent.type == IntentType.addTodo) {
      try {
        await PlatformChannelService.instance.openCalendar();
      } catch (_) {}
    }

    if (intent.type == IntentType.setAlarm) {
      final actionData = intent.parameters;
      final hour = actionData['hour'] as int? ?? 8;
      final minute = actionData['minute'] as int? ?? 0;
      try {
        await PlatformChannelService.instance.openAlarm(hour, minute);
      } catch (_) {}
    }

    if (intent.type == IntentType.setReminder) {
      try {
        await PlatformChannelService.instance.openCalendar();
      } catch (_) {}
    }

    if (intent.type == IntentType.playMusic) {
      final actionData = intent.parameters;
      final songName = actionData['text'] as String?;
      try {
        await PlatformChannelService.instance.openMusic(songName: songName);
      } catch (_) {}
    }

    if (intent.type == IntentType.searchFiles) {
      try {
        await PlatformChannelService.instance.openFiles();
      } catch (_) {}
    }

    if (intent.type == IntentType.systemControl) {
      final actionData = intent.parameters;
      if (actionData.containsKey('volume_action')) {
        final action = actionData['volume_action'] as String;
        final value = actionData['volume_value'] as int? ?? 10;
        try {
          await PlatformChannelService.instance.adjustVolume(action, value);
        } catch (_) {}
      } else {
        try {
          await PlatformChannelService.instance.openSettings();
        } catch (_) {}
      }
    }

    if (intent.type == IntentType.lockPhone) {
      print('Executing lockPhone native command...');
      try {
        await PlatformChannelService.instance.lockPhone();
      } catch (e) {
        print('Error executing lockPhone: $e');
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        state = state.copyWith(
          messages: [
            ...state.messages,
            ConversationMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              content: 'Could not lock phone: $errorMsg. Please ensure you clicked "Activate" on the settings screen that opened.',
              role: 'assistant',
              createdAt: DateTime.now(),
            ),
          ],
        );
      }
    }

    if (intent.type == IntentType.makeCall) {
      final actionData = intent.parameters;
      final contactName = actionData['text'] as String?;
      if (contactName != null && contactName.isNotEmpty) {
        try {
          final contactsStatus = await Permission.contacts.request();
          final phoneStatus = await Permission.phone.request();
          if (contactsStatus.isGranted && phoneStatus.isGranted) {
            await PlatformChannelService.instance.makeCall(contactName);
          }
        } catch (_) {}
      }
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ConversationMessage(
      id: _uuid.v4(),
      role: 'user',
      content: text.trim(),
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isProcessing: true,
    );

    await _repository.addMessage(userMessage);

    // 1. Parse intent immediately and execute action (non-blocking, instant feedback)
    try {
      final intent = await _aiRepository.parseIntent(text.trim());
      _executeIntentAction(intent, text.trim());
    } catch (_) {}

    // 2. Query the LLM for natural text generation
    try {
      final aiResponse = await _aiRepository.processInput(text.trim());

      final assistantMessage = ConversationMessage(
        id: _uuid.v4(),
        role: 'assistant',
        content: aiResponse.text,
        intent: aiResponse.intent,
        createdAt: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, assistantMessage],
        isProcessing: false,
      );

      await _repository.addMessage(assistantMessage);
      
      // Speak the assistant's reply
      TtsService.instance.speak(assistantMessage.content).catchError((_) {});
    } catch (e) {
      final errorMessage = ConversationMessage(
        id: _uuid.v4(),
        role: 'assistant',
        content: 'Sorry, I encountered an error. Please try again.',
        createdAt: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        isProcessing: false,
      );
      
      // Speak the error reply
      TtsService.instance.speak(errorMessage.content).catchError((_) {});
    }
  }

  Future<void> clearHistory() async {
    await _repository.clearHistory();
    state = state.copyWith(messages: []);
  }
}
