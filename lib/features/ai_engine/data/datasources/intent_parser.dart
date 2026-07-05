import '../../domain/entities/intent.dart';

/// Keyword-based intent classifier
class IntentParser {
  static final Map<IntentType, List<String>> _intentKeywords = {
    IntentType.createNote: ['note', 'write', 'jot', 'memo'],
    IntentType.setTimer: ['timer', 'countdown', 'stopwatch'],
    IntentType.setAlarm: ['alarm', 'wake me', 'wake up'],
    IntentType.setReminder: ['remind', 'reminder', 'don\'t forget'],
    IntentType.addTodo: ['todo', 'task', 'to do', 'to-do', 'checklist'],
    IntentType.playMusic: ['music', 'song', 'play', 'playlist', 'audio'],
    IntentType.searchFiles: ['file', 'document', 'pdf', 'search', 'find'],
    IntentType.openApp: ['open', 'launch', 'start', 'run app'],
    IntentType.systemControl: ['bluetooth', 'wifi', 'flashlight', 'torch', 'volume', 'brightness', 'camera', 'calculator', 'settings'],
    IntentType.greeting: ['hello', 'hi', 'hey', 'good morning', 'good afternoon', 'good evening'],
    IntentType.timeQuery: ['time', 'clock', 'hour'],
    IntentType.dateQuery: ['date', 'day', 'today', 'calendar'],
    IntentType.makeCall: ['call', 'dial', 'phone call', 'contact'],
    IntentType.lockPhone: ['lock', 'screen lock'],
  };

  Intent parse(String input) {
    final lower = input.toLowerCase().trim();

    IntentType bestIntent = IntentType.unknown;
    double bestConfidence = 0.0;
    int bestMatchCount = 0;

    for (final entry in _intentKeywords.entries) {
      int matchCount = 0;
      for (final keyword in entry.value) {
        if (lower.contains(keyword)) {
          matchCount++;
        }
      }
      if (matchCount > bestMatchCount) {
        bestMatchCount = matchCount;
        bestIntent = entry.key;
        bestConfidence = matchCount / entry.value.length;
      }
    }

    if (bestMatchCount == 0) {
      bestIntent = IntentType.general;
      bestConfidence = 0.5;
    }

    return Intent(
      type: bestIntent,
      confidence: bestConfidence.clamp(0.0, 1.0),
      parameters: _extractParameters(lower, bestIntent),
    );
  }

  Map<String, dynamic> _extractParameters(String input, IntentType intent) {
    final params = <String, dynamic>{};

    if (intent == IntentType.openApp) {
      String appName = input;
      for (final keyword in ['open app', 'open', 'launch', 'start', 'run app']) {
        final regex = RegExp(RegExp.escape(keyword), caseSensitive: false);
        if (regex.hasMatch(appName)) {
          appName = appName.replaceFirst(regex, '');
        }
      }
      appName = appName.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (appName.isNotEmpty) {
        params['app_name'] = appName;
      }
    }

    if (intent == IntentType.systemControl) {
      int val = 10;
      final volumeMatch = RegExp(r'(\d+)\s*(%|percent)').firstMatch(input);
      if (volumeMatch != null) {
        val = int.parse(volumeMatch.group(1)!);
      } else {
        final numberMatch = RegExp(r'(\d+)').firstMatch(input);
        if (numberMatch != null) {
          val = int.parse(numberMatch.group(1)!);
        }
      }
      params['volume_value'] = val;
      
      if (input.contains('increase') || input.contains('up') || input.contains('raise')) {
        params['volume_action'] = 'increase';
      } else if (input.contains('decrease') || input.contains('down') || input.contains('lower')) {
        params['volume_action'] = 'decrease';
      } else {
        params['volume_action'] = 'set';
      }
    }

    if (intent == IntentType.makeCall) {
      String contactName = input;
      for (final keyword in ['phone call', 'call', 'dial', 'contact']) {
        final regex = RegExp(RegExp.escape(keyword), caseSensitive: false);
        if (regex.hasMatch(contactName)) {
          contactName = contactName.replaceFirst(regex, '');
        }
      }
      contactName = contactName.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (contactName.isNotEmpty) {
        params['text'] = contactName;
      }
    }

    if (intent == IntentType.playMusic) {
      final quotedMatch = RegExp(r'"([^"]*)"').firstMatch(input);
      if (quotedMatch != null) {
        params['text'] = quotedMatch.group(1);
      } else {
        String songName = input;
        for (final keyword in ['play music', 'play song', 'play']) {
          final regex = RegExp(RegExp.escape(keyword), caseSensitive: false);
          if (regex.hasMatch(songName)) {
            songName = songName.replaceFirst(regex, '');
          }
        }
        songName = songName.replaceAll(RegExp(r'\s+'), ' ').trim();
        if (songName.isNotEmpty) {
          params['text'] = songName;
        }
      }
    }

    if (intent == IntentType.createNote) {
      final quotedMatch = RegExp(r'"([^"]*)"').firstMatch(input);
      if (quotedMatch != null) {
        params['text'] = quotedMatch.group(1);
      } else {
        String noteText = input;
        for (final keyword in ['create note', 'take note', 'write note', 'note', 'jot', 'memo']) {
          final regex = RegExp(RegExp.escape(keyword), caseSensitive: false);
          if (regex.hasMatch(noteText)) {
            noteText = noteText.replaceFirst(regex, '');
          }
        }
        noteText = noteText.replaceAll(RegExp(r'\s+'), ' ').trim();
        if (noteText.isNotEmpty) {
          params['text'] = noteText;
        }
      }
    }

    if (intent == IntentType.setAlarm) {
      final timeMatch = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(input);
      if (timeMatch != null) {
        int hour = int.parse(timeMatch.group(1)!);
        int minute = int.parse(timeMatch.group(2)!);
        
        final hasPm = RegExp(r'\bp\.?m\.?\b').hasMatch(input);
        final hasAm = RegExp(r'\ba\.?m\.?\b').hasMatch(input);
        
        if (hasPm && hour < 12) {
          hour += 12;
        } else if (hasAm && hour == 12) {
          hour = 0;
        }
        
        params['hour'] = hour;
        params['minute'] = minute;
      } else {
        final hourMatch = RegExp(r'\b(at|for)?\s*(\d{1,2})\s*([ap]\.?m\.?)?\b').firstMatch(input);
        if (hourMatch != null) {
          int hour = int.parse(hourMatch.group(2)!);
          final ampm = hourMatch.group(3);
          
          final hasPm = ampm != null && RegExp(r'p\.?m\.?').hasMatch(ampm);
          final hasAm = ampm != null && RegExp(r'a\.?m\.?').hasMatch(ampm);
          
          if (hasPm && hour < 12) {
            hour += 12;
          } else if (hasAm && hour == 12) {
            hour = 0;
          }
          
          params['hour'] = hour;
          params['minute'] = 0;
        }
      }
    }

    // Extract numbers (general fallback)
    final numberMatch = RegExp(r'(\d+)').firstMatch(input);
    if (numberMatch != null && !params.containsKey('hour')) {
      params['number'] = int.parse(numberMatch.group(1)!);
    }

    // Extract quoted text (general fallback)
    final quotedMatch = RegExp(r'"([^"]*)"').firstMatch(input);
    if (quotedMatch != null && !params.containsKey('text')) {
      params['text'] = quotedMatch.group(1);
    }

    // Extract "for X minutes/hours" pattern (timers)
    final durationMatch = RegExp(r'for\s+(\d+)\s+(minute|hour|second)s?').firstMatch(input);
    if (durationMatch != null) {
      final value = int.parse(durationMatch.group(1)!);
      final unit = durationMatch.group(2)!;
      params['duration_value'] = value;
      params['duration_unit'] = unit;
    }

    return params;
  }
}
