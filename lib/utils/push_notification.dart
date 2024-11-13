import 'package:elk/utils/local_notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebasePush {
  static Future<String?> enableToken() async {
    final instance = FirebaseMessaging.instance;
    String? token = await instance.getToken();
    return token;
  }

  static Future<void> deleteToken() async {
    final instance = FirebaseMessaging.instance;
    await instance.deleteToken();
  }

  static void subScribeToTopic(String topic) {
    final instance = FirebaseMessaging.instance;
    instance.subscribeToTopic(topic);
  }

  static void unsSubScribeToTopic(String topic) {
    final instance = FirebaseMessaging.instance;
    instance.unsubscribeFromTopic(topic);
  }

  static void inAppMessageHandler(RemoteMessage message) {
    if (message.notification == null) {
      LocalNotification().showDataNotification(message);
    }
  }

  @pragma('vm:entry-point')
  static Future<void> backgroundMessageHandler(RemoteMessage message) async {
    if (message.notification == null) {
      LocalNotification().showDataNotification(message);
    }
  }
    
}
