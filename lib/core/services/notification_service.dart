import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// Centralized notification service with distinct channels
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  // Notification channel IDs
  static const String timerChannelId = 'nova_timer';
  static const String alarmChannelId = 'nova_alarm';
  static const String reminderChannelId = 'nova_reminder';
  static const String generalChannelId = 'nova_general';

  Future<void> initialize() async {
    // Initialize timezone data
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Create notification channels with distinct sounds
    await _createChannels();
  }

  Future<void> _createChannels() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // Timer channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          timerChannelId,
          'Timer Notifications',
          description: 'Notifications for timer completion',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );

      // Alarm channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          alarmChannelId,
          'Alarm Notifications',
          description: 'Notifications for alarms',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        ),
      );

      // Reminder channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          reminderChannelId,
          'Reminder Notifications',
          description: 'Notifications for reminders',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );

      // General channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          generalChannelId,
          'General Notifications',
          description: 'General app notifications',
          importance: Importance.defaultImportance,
        ),
      );
    }
  }

  void _onNotificationResponse(NotificationResponse response) {
    // Handle notification tap — can be extended for deep linking
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Show a simple notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String channelId = generalChannelId,
    String? payload,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          _getChannelName(channelId),
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: payload,
    );
  }

  /// Schedule a notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String channelId = reminderChannelId,
    String? payload,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _convertToTZDateTime(scheduledTime),
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          _getChannelName(channelId),
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Cancel a notification
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  String _getChannelName(String channelId) {
    switch (channelId) {
      case timerChannelId:
        return 'Timer Notifications';
      case alarmChannelId:
        return 'Alarm Notifications';
      case reminderChannelId:
        return 'Reminder Notifications';
      default:
        return 'General Notifications';
    }
  }

  tz.TZDateTime _convertToTZDateTime(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.local);
  }
}
