import 'package:intl/intl.dart';
import 'ai_provider.dart';

/// Working rule-based AI provider that handles common commands
/// This serves as the default fallback when no LLM is loaded
class RuleBasedProvider implements AIProvider {
  bool _isReady = false;

  @override
  String get providerName => 'Rule-Based Engine';

  @override
  bool get isReady => _isReady;

  @override
  Future<void> initialize() async {
    _isReady = true;
  }

  @override
  Future<String> generateResponse(String input, {List<Map<String, String>>? context}) async {
    final lower = input.toLowerCase().trim();

    // Greetings
    if (_matchesAny(lower, ['hello', 'hi', 'hey', 'good morning', 'good afternoon', 'good evening', 'good night'])) {
      return _getGreeting();
    }

    // Time queries
    if (_matchesAny(lower, ['what time', 'current time', 'tell me the time', "what's the time"])) {
      final now = DateTime.now();
      return 'It\'s ${DateFormat('h:mm a').format(now)}.';
    }

    // Date queries
    if (_matchesAny(lower, ['what date', 'today\'s date', 'what day', "what's the date"])) {
      final now = DateTime.now();
      return 'Today is ${DateFormat('EEEE, MMMM d, y').format(now)}.';
    }

    // Name queries
    if (_matchesAny(lower, ['what is your name', 'who are you', "what's your name"])) {
      return 'I\'m Nova, your offline AI assistant. I\'m here to help you with notes, timers, reminders, music, and more!';
    }

    // Capability queries
    if (_matchesAny(lower, ['what can you do', 'help me', 'what are your features', 'capabilities'])) {
      return 'I can help you with:\n'
          '• Creating and managing notes\n'
          '• Setting timers and alarms\n'
          '• Creating reminders and todos\n'
          '• Playing music from your device\n'
          '• Searching your files\n'
          '• Opening apps\n'
          '• And more! Just ask me anything.';
    }

    // Timer commands
    if (_matchesAny(lower, ['set timer', 'start timer', 'timer for', 'set a timer'])) {
      final minutes = _extractNumber(lower);
      if (minutes != null) {
        return 'I\'ll set a timer for $minutes minutes. You can manage your timers in the Timer section.';
      }
      return 'Sure! How many minutes should I set the timer for?';
    }

    // Note commands
    if (_matchesAny(lower, ['create note', 'new note', 'make a note', 'take a note', 'write a note'])) {
      return 'I\'ll open the note editor for you. You can also create notes from the Notes section.';
    }

    // Reminder commands
    if (_matchesAny(lower, ['remind me', 'set reminder', 'create reminder'])) {
      return 'I\'ll help you set a reminder. You can specify the date and time in the Reminders section.';
    }

    // Call commands
    if (_matchesAny(lower, ['call', 'dial'])) {
      String contactName = lower;
      for (final keyword in ['phone call', 'call', 'dial', 'contact']) {
        if (contactName.contains(keyword)) {
          contactName = contactName.replaceFirst(keyword, '');
        }
      }
      contactName = contactName.trim();
      if (contactName.isNotEmpty) {
        return 'Calling $contactName...';
      }
      return 'Sure, who would you like to call?';
    }

    // Music commands
    if (_matchesAny(lower, ['play music', 'play song', 'play some music', 'music'])) {
      return 'Opening your music library. You can play songs from your device\'s storage.';
    }

    // Search commands
    if (_matchesAny(lower, ['search files', 'find file', 'look for', 'search for'])) {
      return 'I\'ll help you search your files. You can also use the File Explorer for more options.';
    }

    // App launch commands
    if (_matchesAny(lower, ['open app', 'launch', 'start app', 'open '])) {
      String appName = lower;
      for (final keyword in ['open app', 'open', 'launch', 'start', 'run app']) {
        if (appName.contains(keyword)) {
          appName = appName.replaceFirst(keyword, '');
        }
      }
      appName = appName.trim();
      if (appName.isNotEmpty) {
        return 'Opening $appName…';
      }
      return 'You can search and open apps from the App Launcher section.';
    }

    // Jokes
    if (_matchesAny(lower, ['tell me a joke', 'joke', 'make me laugh', 'funny'])) {
      final jokes = [
        'Why do programmers prefer dark mode? Because light attracts bugs! 🐛',
        'Why did the AI assistant go to therapy? It had too many unresolved promises! 😄',
        'What\'s an AI\'s favorite snack? Microchips! 🍪',
        'I\'d tell you a joke about UDP, but you might not get it. 📡',
      ];
      return jokes[DateTime.now().millisecond % jokes.length];
    }

    // Thank you
    if (_matchesAny(lower, ['thank you', 'thanks', 'thank', 'appreciate'])) {
      return 'You\'re welcome! Is there anything else I can help you with? 😊';
    }

    // Goodbye
    if (_matchesAny(lower, ['bye', 'goodbye', 'see you', 'quit', 'exit'])) {
      return 'Goodbye! Feel free to ask me anything anytime. 👋';
    }

    // Default response
    return 'Sorry, i cannot do that in rule based engine';
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning! ☀️ How can I help you today?';
    if (hour < 17) return 'Good afternoon! 🌤️ What can I do for you?';
    if (hour < 21) return 'Good evening! 🌅 How can I assist you?';
    return 'Good night! 🌙 Need anything before you rest?';
  }

  bool _matchesAny(String input, List<String> patterns) {
    return patterns.any((p) => input.contains(p));
  }

  int? _extractNumber(String input) {
    final regex = RegExp(r'(\d+)');
    final match = regex.firstMatch(input);
    if (match != null) return int.tryParse(match.group(1)!);
    return null;
  }
}
