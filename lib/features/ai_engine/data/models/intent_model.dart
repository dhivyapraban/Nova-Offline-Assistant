import '../../domain/entities/intent.dart';

class IntentModel extends Intent {
  const IntentModel({
    required super.type,
    super.confidence,
    super.parameters,
  });

  Map<String, dynamic> toMap() => {
    'type': type.name,
    'confidence': confidence,
  };

  factory IntentModel.fromMap(Map<String, dynamic> map) {
    return IntentModel(
      type: IntentType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => IntentType.unknown,
      ),
      confidence: (map['confidence'] as num?)?.toDouble() ?? 1.0,
    );
  }
}
