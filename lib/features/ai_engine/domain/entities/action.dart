class AssistantAction {
  final String actionType;
  final Map<String, dynamic> parameters;

  const AssistantAction({
    required this.actionType,
    this.parameters = const {},
  });

  Map<String, dynamic> toJson() => {
    'actionType': actionType,
    'parameters': parameters,
  };

  factory AssistantAction.fromJson(Map<String, dynamic> json) {
    return AssistantAction(
      actionType: json['actionType'] as String,
      parameters: Map<String, dynamic>.from(json['parameters'] as Map? ?? {}),
    );
  }
}
