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
  bool _isProcessing = false; //czy proces jest w trakcie
  String? _lastScannedCode; //ostatnio zeskanowany kod
  DateTime? _lastScanTime; //czas ostatniego skanowania
  MobileScannerController cameraController = MobileScannerController(); //kontroler kamery

  @override
  void initState() {
    super.initState();
    _ensureValidTokenAndStartCamera();
  }

  Future<void> _ensureValidTokenAndStartCamera() async {
    if (isTokenExpired(Auth.token)) { //sprawdzenie czy token jest ważny
      final refreshed = await Auth.refreshToken(); //odświeżenie tokenu
      if (!refreshed) { //jeśli token nie został odświeżony
        WidgetsBinding.instance.addPostFrameCallback((_) { //dodanie callbacka po zakończeniu renderowania
          Navigator.pushReplacementNamed(context, '/login'); //przejście do ekranu logowania
        });
        return; //zakończenie funkcji
      }
    }
    Future.delayed(Duration(milliseconds: 200), () { //opóźnienie o 200ms
      cameraController.start(); //uruchomienie kamery
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( //ekran
      body: Stack( //stos elementów
        children: [
          MobileScanner( //skaner
            controller: cameraController, //kontroler kamery
            onDetect: (barcode) { //funkcja wykrywania kodów
              if (barcode.barcodes.isNotEmpty) { //jeśli zostały wykryte kody
                final code = barcode.barcodes.first.rawValue; //pobranie pierwszego kodu
                if (code != null) {
                  final now = DateTime.now(); //pobranie aktualnego czasu

                  if (_lastScannedCode == code && //jeśli ostatnio zeskanowany kod jest taki sam jak aktualny
                      _lastScanTime != null &&
                      now.difference(_lastScanTime!).inSeconds < 2) {
                    // Ignorujemy duplikat w ciągu 2s
                    return; //zakończenie funkcji
                  }

                  _lastScannedCode = code; //zapisanie ostatnio zeskanowanego kodu
                  _lastScanTime = now; //zapisanie aktualnego czasu

                  Navigator.pushNamed( //przejście do ekranu produktu
                    context, //kontekst
                    '/product', //ekran produktu
                    arguments: code, //przekazanie kodu do ekranu produktu
                  );
                } //jeśli kod jest null, zakończenie funkcji
              }
            },
          ),
          SafeArea( //obszar bez status bara
            child: Stack( //stos elementów
              children: [ //elementy
                Align( //wyrównanie do góry
                  alignment: Alignment.topCenter, //wyrównanie do środka
                  child: Padding( //padding
                    padding: const EdgeInsets.only(top: 16), //padding górny
                    child: ElevatedButton( //przycisk
                      onPressed: () {
                        Navigator.pushNamed( //przejście do ekranu produktu
                          context, //kontekst
                          '/product', //ekran produktu
                          arguments: "737628064502", //przekazanie kodu do ekranu produktu
                        );
                      },
                      child: Text("Testuj bez skanera"), //tekst przycisku
                    ),
                  ),
                ),
                Align( //wyrównanie do prawej
                  alignment: Alignment.topRight, //wyrównanie do prawej
                  child: Padding( //padding
                    padding: const EdgeInsets.only(top: 16, right: 16), //padding górny i prawy
                    child: Material( //materiał
                      color: Colors.transparent, //kolor przezroczysty
                      child: IconButton( //przycisk
                        icon: Icon(Icons.settings, color: Colors.black87, size: 28), //ikona ustawień
                        onPressed: () async { //funkcja wyświetlania modalnego okienka
                          showModalBottomSheet( //wyświetlenie modalnego okienka
                            context: context, //kontekst
                            shape: RoundedRectangleBorder( //krawędzie zaokrąglone
                              borderRadius: BorderRadius.vertical(top: Radius.circular(24)), //zaokrąglenie górnej części
                            ),
                            builder: (context) => _SettingsSheet(), //funkcja budowania modalnego okienka
                          );
                        }, //funkcja wyświetlania modalnego okienka
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
    cameraController.dispose(); //zamknięcie kamery
    super.dispose(); //zamknięcie ekranu
  }
}

class _SettingsSheet extends StatefulWidget {
  @override
  State<_SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<_SettingsSheet> {
  int? _ttl; //czas życia cache
  int _cacheSize = 0; //liczba produktów w cache
  final _controller = TextEditingController(); //kontroler tekstu
  bool _isClearing = false; //czy jest wyczyszczanie cache

  @override
  void initState() {
    super.initState();
    _load(); //załadowanie ustawień
  }

  Future<void> _load() async {
    final ttl = await ProductCache.getTtlHours(); //pobranie czasu życia cache
    final size = await ProductCache.getCacheSize(); //pobranie liczby produktów w cache
    setState(() { //zaktualizowanie stanu
      _ttl = ttl;
      _controller.text = ttl.toString(); //zaktualizowanie tekstu
      _cacheSize = size; //zaktualizowanie liczby produktów w cache
    });
  }

  Future<void> _saveTtl() async {
    final value = int.tryParse(_controller.text); //pobranie czasu życia cache
    if (value != null && value > 0) { //jeśli czas życia cache jest większy niż 0
      await ProductCache.setTtlHours(value); //zapisanie czasu życia cache
      setState(() { //zaktualizowanie stanu
        _ttl = value;
      }); //zaktualizowanie czasu życia cache
      ScaffoldMessenger.of(context).showSnackBar( //wyświetlenie powiadomienia
        SnackBar(content: Text('Zmieniono TTL na $value godzin.')), //tekst powiadomienia
      );
    }
  }

  Future<void> _clearCache() async {
    setState(() { _isClearing = true; }); //zaktualizowanie stanu
    await ProductCache.clearCache(); //wyczyszczenie cache
    await _load(); //załadowanie ustawień
    setState(() { _isClearing = false; }); //zaktualizowanie stanu
    ScaffoldMessenger.of(context).showSnackBar( //wyświetlenie powiadomienia
      SnackBar(content: Text('Cache wyczyszczony.')), //tekst powiadomienia
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom + 32; //pobranie wysokości ekranu
    return SingleChildScrollView( //przewijanie ekranu
      padding: EdgeInsets.only(bottom: bottomPadding), //padding dolny
      child: Padding(
        padding: const EdgeInsets.all(24.0), //padding
        child: Column( //kolumna
          mainAxisSize: MainAxisSize.min, //główny rozmiar
          crossAxisAlignment: CrossAxisAlignment.start, //wyrównanie do lewej
          children: [
            Row( //wiersz
              children: [ //elementy
                Icon(Icons.settings, color: Colors.grey[700]), //ikona ustawień
                SizedBox(width: 8), //odstęp
                Text('Ustawienia cache', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), //tekst ustawień cache
              ],
            ),
            SizedBox(height: 24), //odstęp
            Text('Czas życia cache (TTL) w godzinach:'), //tekst czasu życia cache
            Row( //wiersz
              children: [ //elementy
                Expanded( //rozszerzenie
                  child: TextField(
                    controller: _controller, //kontroler tekstu
                    keyboardType: TextInputType.number, //typ klawiatury
                    decoration: InputDecoration(hintText: 'TTL (godziny)'), //dekoracja
                  ),
                ),
                SizedBox(width: 12), //odstęp
                ElevatedButton(
                  onPressed: _saveTtl, //zapisanie czasu życia cache
                  child: Text('Zapisz'), //tekst zapisu
                ),
              ],
            ),
            SizedBox(height: 24), //odstęp
            ElevatedButton.icon(
              onPressed: _isClearing ? null : _clearCache, //wyczyszczenie cache
              icon: Icon(Icons.delete), //ikona wyczyszczenia
              label: Text('Wyczyść cache'), //tekst wyczyszczenia
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red), //styling przycisku
            ),
            SizedBox(height: 24), //odstęp
            Text('Liczba produktów w cache: $_cacheSize'), //tekst liczby produktów w cache
          ],
        ),
      ),
    );
  }
}
