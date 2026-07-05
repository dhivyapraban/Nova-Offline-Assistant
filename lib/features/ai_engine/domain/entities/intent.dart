enum IntentType {
  createNote,
  setTimer,
  setAlarm,
  setReminder,
  addTodo,
  playMusic,
  searchFiles,
  openApp,
  systemControl,
  greeting,
  timeQuery,
  dateQuery,
  makeCall,
  lockPhone,
  general,
  unknown,
}

class Intent {
  final IntentType type;
  final double confidence;
  final Map<String, dynamic> parameters;

  const Intent({
    required this.type,
    this.confidence = 1.0,
    this.parameters = const {},
  });

  Intent copyWith({
    IntentType? type,
    double? confidence,
    Map<String, dynamic>? parameters,
  }) {
    return Intent(
      type: type ?? this.type,
      confidence: confidence ?? this.confidence,
      parameters: parameters ?? this.parameters,
    );
  }
}
