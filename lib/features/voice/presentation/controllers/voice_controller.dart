import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/speech_result.dart';
import '../../domain/repositories/speech_repository.dart';
import '../../data/datasources/speech_to_text_service.dart';
import '../../data/repository_impl/speech_repository_impl.dart';
import 'package:nova_assistant/core/services/tts_service.dart';

/// Voice listening state
enum VoiceStatus { idle, listening, processing }

/// Voice listening mode
enum ListeningMode { pushToTalk, continuous }

/// State for the voice controller
class VoiceState {
  final VoiceStatus status;
  final ListeningMode mode;
  final String recognizedText;
  final String partialText;
  final double confidence;
  final List<SpeechResult> history;

  const VoiceState({
    this.status = VoiceStatus.idle,
    this.mode = ListeningMode.pushToTalk,
    this.recognizedText = '',
    this.partialText = '',
    this.confidence = 0.0,
    this.history = const [],
  });

  VoiceState copyWith({
    VoiceStatus? status,
    ListeningMode? mode,
    String? recognizedText,
    String? partialText,
    double? confidence,
    List<SpeechResult>? history,
  }) {
    return VoiceState(
      status: status ?? this.status,
      mode: mode ?? this.mode,
      recognizedText: recognizedText ?? this.recognizedText,
      partialText: partialText ?? this.partialText,
      confidence: confidence ?? this.confidence,
      history: history ?? this.history,
    );
  }

  String get statusText {
    switch (status) {
      case VoiceStatus.idle:
        return mode == ListeningMode.continuous
            ? 'Continuous — tap to pause'
            : 'Tap to speak';
      case VoiceStatus.listening:
        return 'Listening...';
      case VoiceStatus.processing:
        return 'Processing...';
    }
  }

  bool get isContinuous => mode == ListeningMode.continuous;

  String get displayText {
    if (partialText.isNotEmpty) return partialText;
    if (recognizedText.isNotEmpty) return recognizedText;
    return '';
  }
}

/// StateNotifier managing voice listening state and speech recognition.
/// Supports both push-to-talk and continuous listening modes.
/// Reads the listening mode from SharedPreferences on init.
class VoiceController extends StateNotifier<VoiceState> {
  final SpeechRepository _repository;
  StreamSubscription<SpeechResult>? _subscription;
  bool _continuousEnabled = false;

  VoiceController(this._repository) : super(const VoiceState()) {
    _loadListeningMode();
    _listenToStream();
  }

  /// Load listening mode from SharedPreferences (syncs with Settings)
  Future<void> _loadListeningMode() async {
    state = state.copyWith(mode: ListeningMode.pushToTalk);
  }

  void _listenToStream() {
    _subscription = _repository.speechStream.listen(
      (result) {
        if (result.isFinal) {
          state = state.copyWith(
            status: VoiceStatus.idle,
            recognizedText: result.text,
            partialText: '',
            confidence: result.confidence,
            history: [...state.history, result],
          );
        } else {
          state = state.copyWith(
            status: VoiceStatus.listening,
            partialText: result.text,
            confidence: result.confidence,
          );
        }
      },
      onError: (error) {
        state = state.copyWith(status: VoiceStatus.idle, partialText: '');
      },
    );
  }

  /// Toggle listening on/off (used by mic button in both modes)
  Future<void> toggleListening() async {
    if (state.status == VoiceStatus.listening) {
      await stopListening();
    } else {
      await startListening();
    }
  }

  /// Start listening for speech
  Future<void> startListening() async {
    if (!mounted) return;
    try {
      await TtsService.instance.stop();
    } catch (_) {}
    state = state.copyWith(status: VoiceStatus.listening, partialText: '');
    await _repository.startListening();
  }

  /// Stop listening for speech
  Future<void> stopListening() async {
    _continuousEnabled = false;
    state = state.copyWith(status: VoiceStatus.processing);
    await _repository.stopListening();
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (mounted && state.status == VoiceStatus.processing) {
      state = state.copyWith(status: VoiceStatus.idle);
    }
  }

  /// Switch between push-to-talk and continuous — also saves to SharedPreferences
  Future<void> setMode(ListeningMode newMode) async {
    if (state.mode == newMode) return;

    // Stop any current listening first
    if (state.status == VoiceStatus.listening) {
      await _repository.stopListening();
    }
    _continuousEnabled = false;

    state = state.copyWith(mode: newMode, status: VoiceStatus.idle);

    // Persist to SharedPreferences so Settings page stays in sync
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'listening_mode', newMode == ListeningMode.continuous ? 'continuous' : 'push_to_talk');

    // Auto-start continuous mode immediately
    if (newMode == ListeningMode.continuous) {
      _continuousEnabled = true;
      await startListening();
    }
  }

  /// Toggle between push-to-talk and continuous
  Future<void> toggleMode() async {
    final newMode = state.mode == ListeningMode.pushToTalk
        ? ListeningMode.continuous
        : ListeningMode.pushToTalk;
    await setMode(newMode);
  }

  /// Clear recognized text
  void clearText() {
    state = state.copyWith(recognizedText: '', partialText: '');
  }

  @override
  void dispose() {
    _continuousEnabled = false;
    _subscription?.cancel();
    super.dispose();
  }
}

// === Providers ===

final speechRepositoryProvider = Provider<SpeechRepository>((ref) {
  final service = SpeechToTextService();
  final repo = SpeechRepositoryImpl(service);
  ref.onDispose(() => repo.dispose());
  return repo;
});

final voiceControllerProvider =
    StateNotifierProvider<VoiceController, VoiceState>((ref) {
  return VoiceController(ref.read(speechRepositoryProvider));
});
