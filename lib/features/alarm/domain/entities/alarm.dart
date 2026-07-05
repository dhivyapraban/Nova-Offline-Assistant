/// Alarm entity representing a scheduled alarm
class Alarm {
  final String id;
  final String? label;
  final int hour;
  final int minute;
  final bool isEnabled;
  final List<int>? repeatDays; // 0=Sun, 1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat
  final DateTime createdAt;

  const Alarm({
    required this.id,
    this.label,
    required this.hour,
    required this.minute,
    this.isEnabled = true,
    this.repeatDays,
    required this.createdAt,
  });

  Alarm copyWith({
    String? id,
    String? label,
    int? hour,
    int? minute,
    bool? isEnabled,
    List<int>? repeatDays,
    DateTime? createdAt,
  }) {
    return Alarm(
      id: id ?? this.id,
      label: label ?? this.label,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      isEnabled: isEnabled ?? this.isEnabled,
      repeatDays: repeatDays ?? this.repeatDays,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Alarm && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
