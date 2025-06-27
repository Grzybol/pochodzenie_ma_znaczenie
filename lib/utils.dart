import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

bool isTokenExpired(String? token) {
  if (token == null) return true; //jeśli token jest null, zwracamy true

  final parts = token.split('.');
  if (parts.length != 3) return true; //jeśli token nie ma 3 części, zwracamy true

  final payload = base64Url.normalize(parts[1]); //pobranie payload z tokenu
  final decoded = json.decode(utf8.decode(base64Url.decode(payload))); //dekodowanie payload

  final exp = decoded['exp']; //pobranie czasu wygaśnięcia z payload
  if (exp == null) return true; //jeśli czas wygaśnięcia jest null, zwracamy true

  final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000); //konwersja czasu wygaśnięcia na datę
  return DateTime.now().isAfter(expiryDate); //sprawdzenie czy token jest ważny
}

class NotificationUtils {
  static Future<void> showSuccessNotification(String productInfo) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = //konfiguracja powiadomienia dla Androida
    AndroidNotificationDetails(
      'scanner_channel',
      'Scanner Notifications',
      channelDescription: 'Notifications for successful barcode scans',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics = //konfiguracja powiadomienia dla platformy
    NotificationDetails(android: androidPlatformChannelSpecifics);  

    await flutterLocalNotificationsPlugin.show( //pokazanie powiadomienia
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
  static const _prefix = 'product_'; //prefix dla kluczy w cache  
  static const _ttlKey = 'cache_ttl_hours'; //klucz dla czasu trwania cache
  static const _defaultTtlHours = 24; //domyślny czas trwania cache

  static Future<int> getTtlHours() async {
    final prefs = await SharedPreferences.getInstance(); //dostęp do shared preferences
    return prefs.getInt(_ttlKey) ?? _defaultTtlHours; //pobranie czasu trwania cache
  }

  static Future<void> setTtlHours(int hours) async {
    final prefs = await SharedPreferences.getInstance(); //dostęp do shared preferences
    await prefs.setInt(_ttlKey, hours); //zapisanie czasu trwania cache
  }

  static Future<void> saveProduct(String barcode, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance(); //dostęp do shared preferences
    final now = DateTime.now().millisecondsSinceEpoch; //aktualny czas w milisekundach
    final ttl = await getTtlHours(); //czas trwania cache
    final expiry = now + ttl * 3600 * 1000; //czas wygaśnięcia cache
    final value = json.encode({'data': data, 'expiry': expiry}); //zapisanie danych do cache
    await prefs.setString(_prefix + barcode, value); //zapisanie danych do cache
  }

  static Future<Map<String, dynamic>?> getProduct(String barcode) async {
    final prefs = await SharedPreferences.getInstance(); //dostęp do shared preferences
    final value = prefs.getString(_prefix + barcode); //pobranie danych z cache
    if (value == null) return null; //jeśli nie ma danych, zwracamy null
    final decoded = json.decode(value); //dekodowanie danych
    final expiry = decoded['expiry'] as int?; //pobranie czasu wygaśnięcia
    if (expiry == null || DateTime.now().millisecondsSinceEpoch > expiry) {
      await prefs.remove(_prefix + barcode); //usunięcie danych z cache
      return null; //zwracamy null
    }
    return Map<String, dynamic>.from(decoded['data']); //zwracamy dane
  }

  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance(); //dostęp do shared preferences
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefix)).toList(); //pobranie wszystkich kluczy z cache
    for (final k in keys) {
      await prefs.remove(k); //usunięcie danych z cache
    }
  }

  static Future<int> getCacheSize() async {
    final prefs = await SharedPreferences.getInstance(); //dostęp do shared preferences
    return prefs.getKeys().where((k) => k.startsWith(_prefix)).length; //pobranie liczby danych w cache
  }
}

