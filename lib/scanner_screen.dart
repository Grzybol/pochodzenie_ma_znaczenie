import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScannerScreen extends StatefulWidget {
  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _isProcessing = false;
  String? _lastScannedCode;
  DateTime? _lastScanTime;


  void _fetchProductInfo(String barcode) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final url = Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcode.json');
    try {
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data['status'] == 1) {
        final product = data['product'];
        final name = product['product_name'] ?? 'Nieznany produkt';
        final brand = product['brands'] ?? 'Brak marki';
        final country = product['countries'] ?? 'Brak kraju';
        _showDialog("✅ Produkt znaleziony", "Nazwa: $name\nMarka: $brand\nKraj: $country");
      } else {
        _showDialog("❌ Nie znaleziono", "Kod: $barcode");
      }
    } catch (e) {
      _showDialog("Błąd", "Nie udało się pobrać danych.");
    } finally {
      Future.delayed(const Duration(seconds: 1), () {
        setState(() => _isProcessing = false);
      });
    }
  }

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

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
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
}
