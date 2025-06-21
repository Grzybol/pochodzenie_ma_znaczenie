import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pochodzenie_ma_znaczenie/utils.dart';
import 'login_screen.dart';

class ScannerScreen extends StatefulWidget {
  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}



class _ScannerScreenState extends State<ScannerScreen> {
  bool _isProcessing = false;
  String? _lastScannedCode;
  DateTime? _lastScanTime;
  MobileScannerController cameraController = MobileScannerController();

  @override
  void initState() {
    super.initState();
    if (isTokenExpired(Auth.token)) {
      // TODO: wysłać powiadomienie i przekierować na login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
    } else {
      // kamera dopiero jak token ważny
      Future.delayed(Duration(milliseconds: 200), () {
        cameraController.start();
      });
    }
  }



  /*
  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"))
        ],
      ),
    );
  }

   */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (barcode) {
              if (barcode.barcodes.isNotEmpty) {
                final code = barcode.barcodes.first.rawValue;
                if (code != null) {
                  final now = DateTime.now();

                  if (_lastScannedCode == code &&
                      _lastScanTime != null &&
                      now.difference(_lastScanTime!).inSeconds < 2) {
                    // Ignorujemy duplikat w ciągu 2s
                    return;
                  }

                  _lastScannedCode = code;
                  _lastScanTime = now;

                  Navigator.pushNamed(
                    context,
                    '/product',
                    arguments: code,
                  );
                }
              }
            },
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/product',
                      arguments: "737628064502",
                    );
                  },
                  child: Text("Testuj bez skanera"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
