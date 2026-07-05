import '../entities/system_state.dart';

/// Abstract repository for system-level controls.
/// Used by the AI engine to execute system commands.
abstract class SystemRepository {
  /// Retrieves the current system state.
  Future<SystemState> getSystemState();

  /// Toggles Bluetooth on/off.
  Future<void> toggleBluetooth();

  /// Toggles WiFi on/off.
  Future<void> toggleWifi();

  /// Toggles the flashlight on/off.
  Future<void> toggleFlashlight();

  /// Sets the system volume level (0.0 - 1.0).
  Future<void> setVolume(double level);

  /// Sets the screen brightness level (0.0 - 1.0).
  Future<void> setBrightness(double level);

  /// Opens the device camera app.
  Future<void> openCamera();

  /// Opens the device gallery/photos app.
  Future<void> openGallery();

  /// Opens the device calculator app.
  Future<void> openCalculator();

  /// Opens the device system settings.
  Future<void> openSettings();
}
