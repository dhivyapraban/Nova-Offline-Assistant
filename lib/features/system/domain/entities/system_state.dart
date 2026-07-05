/// Represents the current state of system controls.
class SystemState {
  final bool bluetoothEnabled;
  final bool wifiEnabled;
  final bool flashlightOn;
  final double volume;
  final double brightness;

  const SystemState({
    this.bluetoothEnabled = false,
    this.wifiEnabled = false,
    this.flashlightOn = false,
    this.volume = 0.5,
    this.brightness = 0.5,
  });

  SystemState copyWith({
    bool? bluetoothEnabled,
    bool? wifiEnabled,
    bool? flashlightOn,
    double? volume,
    double? brightness,
  }) {
    return SystemState(
      bluetoothEnabled: bluetoothEnabled ?? this.bluetoothEnabled,
      wifiEnabled: wifiEnabled ?? this.wifiEnabled,
      flashlightOn: flashlightOn ?? this.flashlightOn,
      volume: volume ?? this.volume,
      brightness: brightness ?? this.brightness,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemState &&
          runtimeType == other.runtimeType &&
          bluetoothEnabled == other.bluetoothEnabled &&
          wifiEnabled == other.wifiEnabled &&
          flashlightOn == other.flashlightOn &&
          volume == other.volume &&
          brightness == other.brightness;

  @override
  int get hashCode => Object.hash(
        bluetoothEnabled,
        wifiEnabled,
        flashlightOn,
        volume,
        brightness,
      );

  @override
  String toString() =>
      'SystemState(bt: $bluetoothEnabled, wifi: $wifiEnabled, flash: $flashlightOn, vol: $volume, bright: $brightness)';
}
