import 'package:nova_assistant/core/services/platform_channel_service.dart';
import '../../domain/entities/system_state.dart';

class SystemChannelService {
  final PlatformChannelService _channel = PlatformChannelService.instance;

  Future<SystemState> getSystemState() async {
    return SystemState(
      bluetoothEnabled: await _channel.isBluetoothEnabled(),
      wifiEnabled: await _channel.isWifiEnabled(),
      flashlightOn: await _channel.isFlashlightOn(),
      volume: await _channel.getVolume(),
      brightness: await _channel.getBrightness(),
    );
  }

  Future<void> toggleBluetooth() => _channel.toggleBluetooth();
  Future<void> toggleWifi() => _channel.toggleWifi();
  Future<void> toggleFlashlight() => _channel.toggleFlashlight();
  Future<void> setVolume(double level) => _channel.setVolume(level);
  Future<void> setBrightness(double level) => _channel.setBrightness(level);
  Future<void> openCamera() => _channel.openCamera();
  Future<void> openGallery() => _channel.openGallery();
  Future<void> openCalculator() => _channel.openCalculator();
  Future<void> openSettings() => _channel.openSettings();
}
