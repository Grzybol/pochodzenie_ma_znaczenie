import 'package:flutter/material.dart';
import 'package:pochodzenie_ma_znaczenie/utils.dart';
import 'login_screen.dart';
import 'scanner_screen.dart';
import 'product_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); //inicjalizacja Flutter
  print('[main] Starting app initialization'); //logowanie
  await Auth.loadFromPrefs(); //pobranie danych z prefs
  print('[main] Finished Auth.loadFromPrefs'); //logowanie

  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher'); //inicjalizacja Android
  const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid); //inicjalizacja

  await Permission.notification.request(); //zapytanie o uprawnienia do powiadomień

  await flutterLocalNotificationsPlugin.initialize( //inicjalizacja powiadomień
    initializationSettings, //inicjalizacja
    onDidReceiveNotificationResponse: (NotificationResponse response) { //funkcja odpowiedzi na powiadomienie
      // nic nie rób — tylko pusty callback
    }, //funkcja odpowiedzi na powiadomienie
  );

  print('[main] Calling runApp'); //logowanie
  runApp(const MyApp()); //uruchomienie aplikacji
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); //konstruktor

  @override
  Widget build(BuildContext context) {
    return MaterialApp( //ekran
      title: 'Skaner kodów', //tytuł ekranu
      debugShowCheckedModeBanner: false, //ukrycie banera debugowania
      theme: ThemeData( //motyw
        useMaterial3: true, //użycie material3
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green), //kolor ziarna
      ),
      initialRoute: '/login', //inicjalny ekran
      routes: { //trasy
        '/login': (context) => LoginScreen(), //ekran logowania
        '/scanner': (context) => ScannerScreen(), //ekran skanera
        '/product': (context) => ProductScreen(), //ekran produktu
      },
    ); //ekran
  }
}


