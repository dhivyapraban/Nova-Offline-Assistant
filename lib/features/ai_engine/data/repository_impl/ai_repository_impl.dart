import '../../domain/entities/ai_response.dart';
import '../../domain/entities/intent.dart';
import '../../domain/repositories/ai_repository.dart';
import '../datasources/local_llm_provider.dart';
import '../datasources/rule_based_provider.dart';
import '../datasources/intent_parser.dart';

class AIRepositoryImpl implements AIRepository {
  final LocalLLMProvider _llmProvider;
  final RuleBasedProvider _ruleProvider;
  final IntentParser _intentParser;

  /// All dependencies are injected — do NOT instantiate here.
  /// Use [aiRepositoryProvider] from ai_engine_controller.dart.
  AIRepositoryImpl({
    required LocalLLMProvider llmProvider,
    required RuleBasedProvider ruleProvider,
    required IntentParser intentParser,
  })  : _llmProvider = llmProvider,
        _ruleProvider = ruleProvider,
        _intentParser = intentParser;

  @override
  bool get isReady => _llmProvider.isReady || _ruleProvider.isReady;

  @override
  Future<void> initialize() async {
    await _ruleProvider.initialize();
    await _llmProvider.initialize();
  }

  @override
  Future<AIResponse> processInput(String input) async {
    if (!_ruleProvider.isReady) {
      await _ruleProvider.initialize();
    }

    final intent = _intentParser.parse(input);

    // Bypass LLM for action/system intents to prevent local LLM crashes from breaking system tools
    final isActionIntent = intent.type == IntentType.createNote ||
        intent.type == IntentType.setTimer ||
        intent.type == IntentType.setAlarm ||
        intent.type == IntentType.setReminder ||
        intent.type == IntentType.addTodo ||
        intent.type == IntentType.playMusic ||
        intent.type == IntentType.searchFiles ||
        intent.type == IntentType.openApp ||
        intent.type == IntentType.systemControl ||
        intent.type == IntentType.makeCall ||
        intent.type == IntentType.lockPhone;

    String responseText;
    if (isActionIntent) {
      responseText = _getActionResponse(intent);
    } else {
      // Use local LLM if loaded, ready, and the query is conversational; fallback to rule-based provider otherwise
      final activeProvider = _llmProvider.isReady ? _llmProvider : _ruleProvider;
      responseText = await activeProvider.generateResponse(input);
    }

    return AIResponse(
      text: responseText,
      intent: intent.type.name,
      actionData: intent.parameters.isNotEmpty ? intent.parameters : null,
      timestamp: DateTime.now(),
    );
  }

  String _getActionResponse(Intent intent) {
    switch (intent.type) {
      case IntentType.createNote:
        final text = intent.parameters['text'] as String?;
        if (text != null && text.isNotEmpty) {
          return 'I\'ve created a note: "$text"';
        }
        return 'I\'ll open the notes app for you.';
      case IntentType.setTimer:
        final val = intent.parameters['duration_value'] ?? intent.parameters['number'];
        if (val is int) {
          final unit = intent.parameters['duration_unit'] as String? ?? 'minutes';
          return 'I\'ve set a timer for $val $unit.';
        }
        return 'I\'ll open the timer for you.';
      case IntentType.setAlarm:
        final hour = intent.parameters['hour'];
        final minute = intent.parameters['minute'];
        if (hour is int && minute is int) {
          final minuteStr = minute.toString().padLeft(2, '0');
          final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
          final ampm = hour >= 12 ? 'PM' : 'AM';
          return 'I\'ve set an alarm for $displayHour:$minuteStr $ampm.';
        }
        return 'I\'ll set the alarm for you.';
      case IntentType.setReminder:
        return 'I\'ll help you set a reminder.';
      case IntentType.addTodo:
        final text = intent.parameters['text'];
        if (text is String && text.isNotEmpty) {
          return 'I\'ve added the todo task: "$text"';
        }
        return 'I\'ll open the todo list for you.';
      case IntentType.playMusic:
        final song = intent.parameters['text'] as String?;
        if (song != null && song.isNotEmpty) {
          return 'Playing "$song"...';
        }
        return 'Opening your music library...';
      case IntentType.searchFiles:
        return 'Opening files search...';
      case IntentType.openApp:
        final app = intent.parameters['app_name'] ?? intent.parameters['text'];
        if (app is String && app.isNotEmpty) {
          return 'Opening $app...';
        }
        return 'Opening the app launcher...';
      case IntentType.systemControl:
        final actionData = intent.parameters;
        if (actionData.containsKey('volume_action')) {
          final action = actionData['volume_action'] as String;
          final value = actionData['volume_value'] as int? ?? 10;
          if (action == 'increase') {
            return 'Increasing volume by $value%.';
          } else if (action == 'decrease') {
            return 'Decreasing volume by $value%.';
          } else {
            return 'Setting volume to $value%.';
          }
        }
        return 'Opening system settings...';
      case IntentType.lockPhone:
        return 'Locking your phone...';
      case IntentType.makeCall:
        final name = intent.parameters['text'] as String?;
        if (name != null && name.isNotEmpty) {
          return 'Calling $name...';
        }
        return 'Opening the phone dialer...';
      default:
        return 'Command executed successfully.';
    }
  }

  @override
  Future<Intent> parseIntent(String input) async {
    return _intentParser.parse(input);
  }
}
