import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
// Import the global notification instance from main.dart
import 'package:Vewha/main.dart';

class NotificationHelper {
  static Future<void> scheduleNotification(DateTime eventTime, String title) async {
    final notificationTime = eventTime.subtract(const Duration(minutes: 15));

    if (notificationTime.isBefore(DateTime.now())) return;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'calendar_channel_id', 'Calendar Notifications',
      channelDescription: 'Appointment Reminders',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      eventTime.millisecondsSinceEpoch ~/ 1000,
      'Reminder: $title',
      'Your appointment is at ${eventTime.hour}:${eventTime.minute}',
      tz.TZDateTime.from(notificationTime, tz.local),
      details,
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}