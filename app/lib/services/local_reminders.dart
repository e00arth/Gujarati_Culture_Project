import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'daily.dart';

/// [Reminders] through the platform's local notifications. Nothing leaves
/// the phone: the notifications are scheduled on the device itself.
class LocalReminders implements Reminders {
  final _plugin = FlutterLocalNotificationsPlugin();

  /// Sets the plugin up. [onOpen] is called with a [Kehvat.id] when its
  /// notification is tapped, including the tap that launched the app.
  Future<void> start(void Function(String id) onOpen) async {
    tzdata.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } on Exception {
      // The schedule is converted from the reader's local clock either way.
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // Permission is asked for when the reader turns the daily kehvat on.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        if (response.payload case final id?) onOpen(id);
      },
    );
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch != null && launch.didNotificationLaunchApp) {
      if (launch.notificationResponse?.payload case final id?) onOpen(id);
    }
  }

  @override
  Future<bool> allow() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    return await android?.requestNotificationsPermission() ??
        await ios?.requestPermissions(alert: true, sound: true) ??
        false;
  }

  @override
  Future<void> replace(List<Reminder> reminders) async {
    await _plugin.cancelAll();
    for (final (id, reminder) in reminders.indexed) {
      await _plugin.zonedSchedule(
        id: id,
        scheduledDate: tz.TZDateTime.from(reminder.when, tz.local),
        title: reminder.title,
        body: reminder.body,
        payload: reminder.kehvat.id,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'daily',
            reminder.title,
            styleInformation: BigTextStyleInformation(reminder.body),
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        // A few minutes either way is fine, and needs no extra permission.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }
}
