import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class ProductCache {
  static const _prefix = 'product_';
  static const _ttlKey = 'cache_ttl_hours';
  static const _defaultTtlHours = 24;

  static Future<int> getTtlHours() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_ttlKey) ?? _defaultTtlHours;
  }

  static Future<void> setTtlHours(int hours) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_ttlKey, hours);
  }

  static Future<void> saveProduct(String barcode, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    final ttl = await getTtlHours();
    final expiry = now + ttl * 3600 * 1000;
    final value = json.encode({'data': data, 'expiry': expiry});
    await prefs.setString(_prefix + barcode, value);
  }

  static Future<Map<String, dynamic>?> getProduct(String barcode) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_prefix + barcode);
    if (value == null) return null;
    final decoded = json.decode(value);
    final expiry = decoded['expiry'] as int?;
    if (expiry == null || DateTime.now().millisecondsSinceEpoch > expiry) {
      await prefs.remove(_prefix + barcode);
      return null;
    }
    return Map<String, dynamic>.from(decoded['data']);
  }

  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefix)).toList();
    for (final k in keys) {
      await prefs.remove(k);
    }
  }

  static Future<int> getCacheSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getKeys().where((k) => k.startsWith(_prefix)).length;
  }
}

