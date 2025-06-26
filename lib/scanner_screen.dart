import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pochodzenie_ma_znaczenie/utils.dart';
import 'login_screen.dart';
import 'main.dart';

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
    _ensureValidTokenAndStartCamera();
  }

  Future<void> _ensureValidTokenAndStartCamera() async {
    if (isTokenExpired(Auth.token)) {
      final refreshed = await Auth.refreshToken();
      if (!refreshed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, '/login');
        });
        return;
      }
    }
    Future.delayed(Duration(milliseconds: 200), () {
      cameraController.start();
    });
  }

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
            child: Stack(
              children: [
                Align(
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
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, right: 16),
                    child: Material(
                      color: Colors.transparent,
                      child: IconButton(
                        icon: Icon(Icons.settings, color: Colors.black87, size: 28),
                        onPressed: () async {
                          showModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                            ),
                            builder: (context) => _SettingsSheet(),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
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

class _SettingsSheet extends StatefulWidget {
  @override
  State<_SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<_SettingsSheet> {
  int? _ttl;
  int _cacheSize = 0;
  final _controller = TextEditingController();
  bool _isClearing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ttl = await ProductCache.getTtlHours();
    final size = await ProductCache.getCacheSize();
    setState(() {
      _ttl = ttl;
      _controller.text = ttl.toString();
      _cacheSize = size;
    });
  }

  Future<void> _saveTtl() async {
    final value = int.tryParse(_controller.text);
    if (value != null && value > 0) {
      await ProductCache.setTtlHours(value);
      setState(() {
        _ttl = value;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Zmieniono TTL na $value godzin.')),
      );
    }
  }

  Future<void> _clearCache() async {
    setState(() { _isClearing = true; });
    await ProductCache.clearCache();
    await _load();
    setState(() { _isClearing = false; });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cache wyczyszczony.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom + 32;
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: Colors.grey[700]),
                SizedBox(width: 8),
                Text('Ustawienia cache', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 24),
            Text('Czas życia cache (TTL) w godzinach:'),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(hintText: 'TTL (godziny)'),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _saveTtl,
                  child: Text('Zapisz'),
                ),
              ],
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isClearing ? null : _clearCache,
              icon: Icon(Icons.delete),
              label: Text('Wyczyść cache'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
            SizedBox(height: 24),
            Text('Liczba produktów w cache: $_cacheSize'),
          ],
        ),
      ),
    );
  }
}
