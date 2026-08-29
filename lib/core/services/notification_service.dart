import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Service for handling local and scheduled device notifications.
/// Fully isolated for cross-platform compatibility (Android, Web, iOS, Desktop).
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Dedicated Android Notification Channel for Genomic Cancer Intelligence
  static const String channelId = 'genomic_health_reminders';
  static const String channelName = 'Health Reminders';
  static const String channelDescription =
      'Scheduled reminders for medications, cancer screenings, and personalized health guidance';

  /// Initializes the local notification plugin and timezone database
  Future<void> initialize({
    void Function(NotificationResponse)? onNotificationTap,
  }) async {
    if (_isInitialized) return;

    try {
      // 1. Initialize timezone database and detect physical device's local timezone
      tz.initializeTimeZones();
      try {
        if (!kIsWeb) {
          final tzInfo = await FlutterTimezone.getLocalTimezone();
          final String currentTimeZone = tzInfo.identifier;
          tz.setLocalLocation(tz.getLocation(currentTimeZone));
          debugPrint('NotificationService: Device timezone detected & set to $currentTimeZone (tz.local=${tz.local.name})');
        }
      } catch (tzErr) {
        debugPrint('NotificationService: Warning - Could not obtain device timezone: $tzErr');
        try {
          // Fallback to UTC if timezone name is unrecognized
          tz.setLocalLocation(tz.getLocation('UTC'));
        } catch (_) {}
      }

      // 2. Platform initialization settings
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const linuxSettings = LinuxInitializationSettings(
        defaultActionName: 'Open notification',
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
        linux: linuxSettings,
      );

      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: onNotificationTap ??
            (NotificationResponse response) {
              debugPrint('Notification tapped with payload: ${response.payload}');
            },
      );

      // 3. Create High-Priority Notification Channel on Android
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        final androidImplementation =
            _notificationsPlugin.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        if (androidImplementation != null) {
          const androidChannel = AndroidNotificationChannel(
            channelId,
            channelName,
            description: channelDescription,
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
            showBadge: true,
            enableLights: true,
          );

          await androidImplementation.createNotificationChannel(androidChannel);
        }
      }

      _isInitialized = true;
      debugPrint('NotificationService successfully initialized.');
    } catch (e) {
      debugPrint('Error initializing NotificationService: $e');
    }
  }

  /// Request runtime notification permissions (required on Android 13+ / iOS)
  Future<bool> requestPermissions() async {
    if (kIsWeb) return true;

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidImplementation =
            _notificationsPlugin.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        if (androidImplementation != null) {
          // Request POST_NOTIFICATIONS permission for Android 13+ (API 33+)
          final bool? grantedNotification =
              await androidImplementation.requestNotificationsPermission();

          // Request Exact Alarm permission if available
          try {
            await androidImplementation.requestExactAlarmsPermission();
          } catch (e) {
            debugPrint('Exact alarms permission check: $e');
          }

          return grantedNotification ?? false;
        }
      } else if (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        final iosImplementation =
            _notificationsPlugin.resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        if (iosImplementation != null) {
          final bool? granted = await iosImplementation.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
          return granted ?? false;
        }
      }
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
    }
    return false;
  }

  /// Notification details configuration
  NotificationDetails _getNotificationDetails() {
    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Genomic Health Reminder',
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF00E5FF), // App Neon Cyan accent
      enableLights: true,
      enableVibration: true,
      playSound: true,
      category: AndroidNotificationCategory.reminder,
      visibility: NotificationVisibility.public,
      fullScreenIntent: false,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return const NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );
  }

  /// Shows an instant local device notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await _notificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: _getNotificationDetails(),
        payload: payload,
      );
      debugPrint('Instant notification displayed: id=$id, title=$title');
    } catch (e) {
      debugPrint('Error showing instant notification: $e');
    }
  }

  /// Schedules a local notification at a specific [DateTime].
  /// Uses Android exact alarms to ensure it triggers when app is closed / screen locked.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      if (kIsWeb) {
        debugPrint('Web: Scheduled notification logged for $scheduledDate: $title');
        return;
      }

      // Convert DateTime to TZDateTime in local timezone
      final tz.Location localLocation = tz.local;
      final tz.TZDateTime tzScheduledDate = tz.TZDateTime(
        localLocation,
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
        scheduledDate.hour,
        scheduledDate.minute,
        scheduledDate.second,
      );

      // If scheduled time has already passed today, don't schedule in past
      if (tzScheduledDate.isBefore(tz.TZDateTime.now(localLocation))) {
        debugPrint('Scheduled time $tzScheduledDate is in the past.');
        return;
      }

      try {
        await _notificationsPlugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: tzScheduledDate,
          notificationDetails: _getNotificationDetails(),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: payload,
        );
      } catch (exactErr) {
        debugPrint('Exact alarm failed ($exactErr), retrying with inexactAllowWhileIdle');
        await _notificationsPlugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: tzScheduledDate,
          notificationDetails: _getNotificationDetails(),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: payload,
        );
      }

      debugPrint(
          'Notification scheduled successfully: id=$id at $tzScheduledDate ($title)');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  /// Schedules a repeating daily notification (e.g., Daily medicine at a fixed hour & minute)
  Future<void> scheduleRepeatingDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      if (kIsWeb) {
        debugPrint('Web: Daily notification logged for $hour:$minute: $title');
        return;
      }

      final tz.Location localLocation = tz.local;
      final tz.TZDateTime now = tz.TZDateTime.now(localLocation);
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        localLocation,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // If today's time has already passed, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      try {
        await _notificationsPlugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          notificationDetails: _getNotificationDetails(),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: payload,
        );
      } catch (exactErr) {
        debugPrint('Daily exact alarm failed ($exactErr), retrying with inexactAllowWhileIdle');
        await _notificationsPlugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          notificationDetails: _getNotificationDetails(),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: payload,
        );
      }

      debugPrint(
          'Daily repeating notification scheduled: id=$id at $hour:$minute ($title) on $scheduledDate');
    } catch (e) {
      debugPrint('Error scheduling daily repeating notification: $e');
    }
  }

  /// Schedules a repeating weekly notification (e.g., Weekly health check on a specific day & time)
  Future<void> scheduleRepeatingWeeklyNotification({
    required int id,
    required String title,
    required String body,
    required int dayOfWeek, // 1 for Monday, 7 for Sunday
    required int hour,
    required int minute,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      if (kIsWeb) {
        debugPrint('Web: Weekly notification logged for day $dayOfWeek at $hour:$minute: $title');
        return;
      }

      final tz.Location localLocation = tz.local;
      final tz.TZDateTime now = tz.TZDateTime.now(localLocation);
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        localLocation,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      while (scheduledDate.weekday != dayOfWeek || scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      try {
        await _notificationsPlugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          notificationDetails: _getNotificationDetails(),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          payload: payload,
        );
      } catch (exactErr) {
        debugPrint('Weekly exact alarm failed ($exactErr), retrying with inexactAllowWhileIdle');
        await _notificationsPlugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          notificationDetails: _getNotificationDetails(),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          payload: payload,
        );
      }

      debugPrint(
          'Weekly repeating notification scheduled: id=$id on day $dayOfWeek at $hour:$minute ($title) on $scheduledDate');
    } catch (e) {
      debugPrint('Error scheduling weekly repeating notification: $e');
    }
  }

  /// Cancels a specific scheduled notification by ID
  Future<void> cancelNotification(int id) async {
    try {
      await _notificationsPlugin.cancel(id: id);
      debugPrint('Cancelled notification id=$id');
    } catch (e) {
      debugPrint('Error cancelling notification id=$id: $e');
    }
  }

  /// Cancels all scheduled notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      debugPrint('Cancelled all scheduled notifications.');
    } catch (e) {
      debugPrint('Error cancelling all notifications: $e');
    }
  }
}
