import 'package:elk/utils/notification_channels.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotification {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initializeNotification() async {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('ic_launcher');
    var initializationSettingsIOS = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await FlutterLocalNotificationsPlugin().initialize(
      initializationSettings,
    );
  }

  Future<void> showDataNotification(RemoteMessage message) async {
    final bigPicture =
        await NotificationChanels().bigPicture(message.data['image']);
    final NotificationDetails notificationDetails = NotificationDetails(
        android: NotificationChanels.generalNotification(bigPicture));
    await flutterLocalNotificationsPlugin.show(
        1, message.data['title'], message.data['body'], notificationDetails);
  }
}
