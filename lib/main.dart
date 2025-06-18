import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'scanner_screen.dart';
import 'product_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skaner kodów',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/scanner': (context) => ScannerScreen(),
        '/product': (context) => ProductScreen(),
      },
    );
  }
}
