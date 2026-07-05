import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

/// Centralized permission handling service
class PermissionService {
  PermissionService._();
  static final PermissionService instance = PermissionService._();

  /// Request microphone permission for voice features
  Future<bool> requestMicrophone() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Request storage permissions for music and file features
  Future<bool> requestStorage() async {
    // Android 13+ uses granular media permissions
    if (await Permission.photos.status.isDenied) {
      await Permission.photos.request();
    }
    if (await Permission.audio.status.isDenied) {
      await Permission.audio.request();
    }
    if (await Permission.videos.status.isDenied) {
      await Permission.videos.request();
    }

    // Fallback for older Android
    if (await Permission.storage.status.isDenied) {
      await Permission.storage.request();
    }

    return await Permission.audio.isGranted || await Permission.storage.isGranted;
  }

  /// Request notification permission (Android 13+)
  Future<bool> requestNotification() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Request all essential permissions
  Future<Map<Permission, PermissionStatus>> requestEssentialPermissions() async {
    return await [
      Permission.microphone,
      Permission.notification,
    ].request();
  }

  /// Check if a specific permission is granted
  Future<bool> isGranted(Permission permission) async {
    return await permission.isGranted;
  }

  /// Open app settings for manual permission grant
  Future<void> openSettings() async {
    await openAppSettings();
  }

  /// Show permission dialog
  static Future<bool> showPermissionDialog(
    BuildContext context, {
    required String title,
    required String message,
    required Future<bool> Function() onRequest,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final granted = await onRequest();
              if (context.mounted) {
                Navigator.of(context).pop(granted);
              }
            },
            child: const Text('Grant'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
