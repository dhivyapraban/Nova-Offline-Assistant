import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await _flutterTts.awaitSpeakCompletion(true);
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.5); // natural reading speed
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      _isInitialized = true;
    } catch (e) {
      // ignore initialization failures
    }
  }

  Future<void> speak(String text, {bool awaitCompletion = false}) async {
    await init();
    try {
      final cleanText = text.trim();
      if (cleanText.isEmpty) return;

      await _flutterTts.stop();

      if (awaitCompletion) {
        final completer = Completer<void>();
        _flutterTts.setCompletionHandler(() {
          if (!completer.isCompleted) completer.complete();
        });
        _flutterTts.setErrorHandler((_) {
          if (!completer.isCompleted) completer.complete();
        });
        _flutterTts.setCancelHandler(() {
          if (!completer.isCompleted) completer.complete();
        });

        await _flutterTts.speak(cleanText);

        // Dynamic safety timeout: estimate ~450ms per word + 1.5s padding
        final wordCount = cleanText.split(' ').length;
        final expectedDurationMs = (wordCount * 450) + 1500;

        await completer.future.timeout(
          Duration(milliseconds: expectedDurationMs),
          onTimeout: () {
            if (!completer.isCompleted) completer.complete();
          },
        );
      } else {
        await _flutterTts.speak(cleanText);
      }
    } catch (e) {
      // ignore speaking errors
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      // ignore
    }
  }
}
