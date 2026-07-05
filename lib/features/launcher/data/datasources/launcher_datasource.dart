import 'package:flutter/services.dart';

import '../models/installed_app_model.dart';

/// Datasource that communicates with native Android via MethodChannel
/// to retrieve installed apps and launch them.
class LauncherDatasource {
  static const _channel = MethodChannel('com.nova.nova_assistant/launcher');

  /// Placeholder apps used when running on emulator or when
  /// the platform channel is not available.
  static const List<Map<String, dynamic>> _placeholderApps = [
    {'packageName': 'com.android.chrome', 'appName': 'Chrome', 'versionName': '125.0'},
    {'packageName': 'com.android.camera', 'appName': 'Camera', 'versionName': '9.0'},
    {'packageName': 'com.android.calculator', 'appName': 'Calculator', 'versionName': '8.5'},
    {'packageName': 'com.android.calendar', 'appName': 'Calendar', 'versionName': '2024.1'},
    {'packageName': 'com.android.contacts', 'appName': 'Contacts', 'versionName': '4.0'},
    {'packageName': 'com.android.dialer', 'appName': 'Phone', 'versionName': '14.0'},
    {'packageName': 'com.android.deskclock', 'appName': 'Clock', 'versionName': '7.5'},
    {'packageName': 'com.android.email', 'appName': 'Email', 'versionName': '6.0'},
    {'packageName': 'com.android.gallery', 'appName': 'Gallery', 'versionName': '5.0'},
    {'packageName': 'com.android.maps', 'appName': 'Maps', 'versionName': '11.0'},
    {'packageName': 'com.android.messaging', 'appName': 'Messages', 'versionName': '12.0'},
    {'packageName': 'com.android.music', 'appName': 'Music', 'versionName': '4.0'},
    {'packageName': 'com.android.notes', 'appName': 'Notes', 'versionName': '3.0'},
    {'packageName': 'com.android.photos', 'appName': 'Photos', 'versionName': '6.0'},
    {'packageName': 'com.android.settings', 'appName': 'Settings', 'versionName': '14.0'},
    {'packageName': 'com.android.vending', 'appName': 'Play Store', 'versionName': '40.0'},
    {'packageName': 'com.android.weather', 'appName': 'Weather', 'versionName': '2.0'},
    {'packageName': 'com.android.youtube', 'appName': 'YouTube', 'versionName': '19.0'},
    {'packageName': 'com.android.files', 'appName': 'Files', 'versionName': '1.0'},
    {'packageName': 'com.android.recorder', 'appName': 'Recorder', 'versionName': '4.0'},
    {'packageName': 'com.android.drive', 'appName': 'Drive', 'versionName': '2.0'},
    {'packageName': 'com.android.docs', 'appName': 'Docs', 'versionName': '1.0'},
    {'packageName': 'com.android.sheets', 'appName': 'Sheets', 'versionName': '1.0'},
    {'packageName': 'com.android.translate', 'appName': 'Translate', 'versionName': '8.0'},
  ];

  /// Retrieves all installed apps from the native platform.
  /// Falls back to placeholder data if the channel is unavailable.
  Future<List<InstalledAppModel>> getInstalledApps() async {
    try {
      final List<dynamic>? result = await _channel.invokeMethod('getInstalledApps');
      if (result != null && result.isNotEmpty) {
        return result
            .cast<Map<dynamic, dynamic>>()
            .map((map) => InstalledAppModel.fromMap(Map<String, dynamic>.from(map)))
            .toList();
      }
      return _getPlaceholderApps();
    } on MissingPluginException {
      // Platform channel not registered — return placeholder data
      return _getPlaceholderApps();
    } on PlatformException {
      return _getPlaceholderApps();
    }
  }

  /// Launches an app by its package name.
  /// Returns true if the app was successfully launched.
  Future<bool> launchApp(String packageName) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'launchApp',
        {'packageName': packageName},
      );
      return result ?? false;
    } on MissingPluginException {
      // Platform channel not available on emulator
      return false;
    } on PlatformException {
      return false;
    }
  }

  /// Returns placeholder apps for emulator / development use.
  List<InstalledAppModel> _getPlaceholderApps() {
    return _placeholderApps
        .map((map) => InstalledAppModel.fromMap(map))
        .toList();
  }
}
