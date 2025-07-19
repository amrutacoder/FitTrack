import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzData;

class NotificationService {
  static final FlutterLocalNotificationsPlugin notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tzData.initializeTimeZones();
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings =
    InitializationSettings(android: androidSettings);
    await notificationsPlugin.initialize(settings);
  }

  tz.TZDateTime _convertToTZ(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.local);
  }

  Future<void> scheduleNotification(int id, String name, String dose, DateTime time) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'medication_channel',
      'Medication Reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await notificationsPlugin.zonedSchedule(
      id,
      'Medication Reminder',
      'Take your $name ($dose)',
      _convertToTZ(time), // ✅ Converts to local time zone
      details,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Required in newer versions
    );

  }
}
