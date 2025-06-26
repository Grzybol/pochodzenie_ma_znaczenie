import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

bool isTokenExpired(String? token) {
  if (token == null) return true;

  final parts = token.split('.');
  if (parts.length != 3) return true;

  final payload = base64Url.normalize(parts[1]);
  final decoded = json.decode(utf8.decode(base64Url.decode(payload)));

  final exp = decoded['exp'];
  if (exp == null) return true;

  final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
  return DateTime.now().isAfter(expiryDate);
}

class NotificationUtils {
  static Future<void> showSuccessNotification(String productInfo) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'scanner_channel',
      'Scanner Notifications',
      channelDescription: 'Notifications for successful barcode scans',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      '✅ Sukces',
      'Zeskanowano produkt: $productInfo',
      platformChannelSpecifics,
    );
  }
}

/*
void showSuccessNotification(String productInfo) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'scanner_channel',
    'Scanner Notifications',
    channelDescription: 'Notifications for successful barcode scans',
    importance: Importance.high,
    priority: Priority.high,
  );
  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    '✅ Sukces',
    'Zeskanowano produkt: $productInfo',
    platformChannelSpecifics,
  );
}

 */
Future<void> showTokenExpiredNotification() async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'token_channel_id',
    'Token Expiry Notifications',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0,
    'Sesja wygasła',
    'Musisz się ponownie zalogować',
    platformDetails,
  );
}

