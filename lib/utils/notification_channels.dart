// ignore_for_file: depend_on_referenced_packages

import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationChanels {
  Future<Uint8List> _getByteArrayFromUrl(String url) async {
    final http.Response response = await http.get(Uri.parse(url));
    return response.bodyBytes;
  }

  Future<BigPictureStyleInformation> bigPicture(String url) async {
    Uint8List data = await _getByteArrayFromUrl(url);
    final ByteArrayAndroidBitmap androidBitmap = ByteArrayAndroidBitmap(data);
    return BigPictureStyleInformation(androidBitmap, largeIcon: androidBitmap);
  }

  static AndroidNotificationDetails generalNotification(
      BigPictureStyleInformation? style) {
    return AndroidNotificationDetails('General', 'General',
        channelDescription: 'General notification',
        importance: Importance.max,
        priority: Priority.high,
        styleInformation: style,
        ticker: 'ticker');
  }
}
