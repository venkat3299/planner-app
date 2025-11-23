import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationsService {
  NotificationsService._();
  static final NotificationsService instance = NotificationsService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    
    // Request permissions (Android 13+)
    final bool? granted = await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    
    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'trip_planner',
      'Trip Planner Notifications',
      description: 'Notifications for trip reminders and alerts',
      importance: Importance.high,
    );
    await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
    
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  Future<void> showNow({
    required String title,
    required String body,
  }) async {
    await init();
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'trip_planner',
          'Trip Planner Notifications',
          channelDescription: 'Notifications for trip reminders and alerts',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: 'trip_planner',
    );
  }

  Future<void> scheduleInSeconds({
    required String title,
    required String body,
    int seconds = 10,
  }) async {
    await init();
    try {
      final tz.TZDateTime when = tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds));
      await _plugin.zonedSchedule(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        when,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'trip_planner',
            'Trip Planner Notifications',
            channelDescription: 'Notifications for trip reminders and alerts',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'trip_planner',
      );
    } catch (e) {
      // Fallback: show notification immediately if exact alarms aren't permitted
      await showNow(title: title, body: body);
    }
  }

  /// Schedule a reminder for a specific date and time
  /// Example: scheduleReminder(title: 'Flight Reminder', body: 'Your flight is in 2 hours', scheduledDate: DateTime.now().add(Duration(hours: 2)))
  Future<void> scheduleReminder({
    required String title,
    required String body,
    required DateTime scheduledDate,
    int? notificationId,
  }) async {
    await init();
    try {
      final tz.TZDateTime when = tz.TZDateTime.from(scheduledDate, tz.local);
      await _plugin.zonedSchedule(
        notificationId ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        when,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'trip_planner',
            'Trip Planner Notifications',
            channelDescription: 'Notifications for trip reminders and alerts',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'trip_planner',
      );
    } catch (e) {
      // Fallback: show notification immediately if exact alarms aren't permitted
      await showNow(title: title, body: body);
    }
  }
}


