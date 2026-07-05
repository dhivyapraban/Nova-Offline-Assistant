import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local_llm_provider.dart';
import '../../data/datasources/rule_based_provider.dart';
import '../../data/datasources/intent_parser.dart';
import '../../data/repository_impl/ai_repository_impl.dart';
import '../../domain/repositories/ai_repository.dart';

// ─── Singleton providers so state persists across rebuilds ───────────────────

final localLLMProviderSingleton = Provider<LocalLLMProvider>((ref) {
  return LocalLLMProvider();
});

final ruleBasedProviderSingleton = Provider<RuleBasedProvider>((ref) {
  final p = RuleBasedProvider();
  p.initialize();
  return p;
});

final intentParserSingleton = Provider<IntentParser>((ref) {
  return IntentParser();
});

final aiRepositoryProvider = Provider<AIRepository>((ref) {
  return AIRepositoryImpl(
    llmProvider: ref.watch(localLLMProviderSingleton),
    ruleProvider: ref.watch(ruleBasedProviderSingleton),
    intentParser: ref.watch(intentParserSingleton),
  );
});

// ─── AI Engine status controller ─────────────────────────────────────────────

enum AIEngineStatus { idle, loading, ready, error }

class AIEngineState {
  final AIEngineStatus status;
  final String statusMessage;
  final bool isLLMActive;

  const AIEngineState({
    this.status = AIEngineStatus.idle,
    this.statusMessage = 'Rule-based engine active',
    this.isLLMActive = false,
  });

  AIEngineState copyWith({
    AIEngineStatus? status,
    String? statusMessage,
    bool? isLLMActive,
  }) =>
      AIEngineState(
        status: status ?? this.status,
        statusMessage: statusMessage ?? this.statusMessage,
        isLLMActive: isLLMActive ?? this.isLLMActive,
      );
}

final aiEngineControllerProvider =
    StateNotifierProvider<AIEngineController, AIEngineState>((ref) {
  return AIEngineController(ref.watch(localLLMProviderSingleton));
});

class AIEngineController extends StateNotifier<AIEngineState> {
  final LocalLLMProvider _llmProvider;

  AIEngineController(this._llmProvider) : super(const AIEngineState()) {
    // Auto-initialize on startup using stored model path
    _initFromPrefs();
  }

  Future<void> _initFromPrefs() async {
    await _llmProvider.initialize();
    if (_llmProvider.isReady) {
      state = state.copyWith(
        status: AIEngineStatus.ready,
        statusMessage: 'Local LLM active (${_llmProvider.loadedModelName})',
        isLLMActive: true,
      );
    } else {
      state = state.copyWith(
        status: AIEngineStatus.ready,
        statusMessage: 'Rule-based engine active',
        isLLMActive: false,
      );
    }
  }

  /// Called from Settings when a new model path is selected
  Future<void> loadModel(String path) async {
    state = state.copyWith(
      status: AIEngineStatus.loading,
      statusMessage: 'Loading model…',
      isLLMActive: false,
    );

    await _llmProvider.loadModel(path);

    if (_llmProvider.isReady) {
      state = state.copyWith(
        status: AIEngineStatus.ready,
        statusMessage: 'Local LLM active (${_llmProvider.loadedModelName})',
        isLLMActive: true,
      );
    } else if (_llmProvider.isFileReady) {
      // File found on device but libllama.so is not bundled in this APK build
      state = state.copyWith(
        status: AIEngineStatus.ready,
        statusMessage:
            'Model file ready — libllama.so not bundled yet (rule-based active)',
        isLLMActive: false,
      );
    } else {
      state = state.copyWith(
        status: AIEngineStatus.error,
        statusMessage: 'Model file not found — check the file path',
        isLLMActive: false,
      );
    }
  }

  /// Unload LLM and fall back to rule-based engine
  Future<void> unloadModel() async {
    await _llmProvider.unload();
    state = state.copyWith(
      status: AIEngineStatus.idle,
      statusMessage: 'Rule-based engine active',
      isLLMActive: false,
    );
  }
}
