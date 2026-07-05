import 'dart:io';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ai_provider.dart';

/// Real MethodChannel-based implementation of local LLM provider supporting llama.cpp.
/// Delegates the native C++ loading and inference to Android LlamaService via platform channels.
class LocalLLMProvider implements AIProvider {
  static const _channel = MethodChannel('com.nova.nova_assistant/llama');

  bool _isReady = false;
  bool _isFileReady = false; // true if GGUF file found, even if loading failed/missing
  String? _loadedModelName;

  @override
  String get providerName => 'Local LLM (llama.cpp)';

  @override
  bool get isReady => _isReady;

  /// True when the .gguf file exists on the device
  bool get isFileReady => _isFileReady;

  /// Returns just the filename of the loaded model (e.g. "gemma-3-1b-it-Q4_K_M.gguf")
  String get loadedModelName => _loadedModelName ?? 'unknown';

  /// Reads the saved model path from SharedPreferences and loads if found.
  @override
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    // Matches the key used in SettingsRepositoryImpl
    final path = prefs.getString('model_path');
    if (path != null && path.isNotEmpty) {
      await loadModel(path);
    }
  }

  /// Load a GGUF model from [modelPath]. Sets [isReady] on success.
  Future<void> loadModel(String modelPath) async {
    _isReady = false;
    _isFileReady = false;
    _loadedModelName = null;

    if (!File(modelPath).existsSync()) {
      // File not found on device
      return;
    }
    _isFileReady = true; // File exists!

    try {
      // Load the model through the native Android method channel
      final bool? success = await _channel.invokeMethod<bool>('loadModel', {
        'path': modelPath,
        'nCtx': 512,
        'nThreads': 2,
      });

      if (success == true) {
        _loadedModelName = modelPath.split('/').last.split('\\').last;
        _isReady = true;
      }
    } catch (_) {
      _isReady = false;
    }
  }

  /// Unload the currently loaded model and free resources.
  Future<void> unload() async {
    try {
      await _channel.invokeMethod('freeModel');
    } catch (_) {
      // ignore
    }
    _isReady = false;
    _isFileReady = false;
    _loadedModelName = null;
  }

  String _formatPrompt(String input) {
    return '<start_of_turn>user\n$input<end_of_turn>\n<start_of_turn>model\n';
  }

  @override
  Future<String> generateResponse(String input, {List<Map<String, String>>? context}) async {
    // If the channel says model isn't loaded, check one more time
    try {
      final bool? loaded = await _channel.invokeMethod<bool>('isModelLoaded');
      if (loaded != true) {
        _isReady = false;
      }
    } catch (_) {
      _isReady = false;
    }

    if (!_isReady) {
      return 'Local LLM is not initialized. Please place libllama.so in jniLibs and select a GGUF model in Settings → AI Model.';
    }

    try {
      final formattedPrompt = _formatPrompt(input);
      final String? response = await _channel.invokeMethod<String>('runInference', {
        'prompt': formattedPrompt,
        'maxNewTokens': 256,
      });
      return response ?? 'Error: empty response generated';
    } catch (e) {
      return 'Local LLM inference error: $e';
    }
  }
}
