import '../../domain/entities/system_state.dart';
import '../../domain/repositories/system_repository.dart';
import '../datasources/system_channel_service.dart';

class SystemRepositoryImpl implements SystemRepository {
  final SystemChannelService _service;
  SystemRepositoryImpl(this._service);

  @override Future<SystemState> getSystemState() => _service.getSystemState();
  @override Future<void> toggleBluetooth() => _service.toggleBluetooth();
  @override Future<void> toggleWifi() => _service.toggleWifi();
  @override Future<void> toggleFlashlight() => _service.toggleFlashlight();
  @override Future<void> setVolume(double level) => _service.setVolume(level);
  @override Future<void> setBrightness(double level) => _service.setBrightness(level);
  @override Future<void> openCamera() => _service.openCamera();
  @override Future<void> openGallery() => _service.openGallery();
  @override Future<void> openCalculator() => _service.openCalculator();
  @override Future<void> openSettings() => _service.openSettings();
}
