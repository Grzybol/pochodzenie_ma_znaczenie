import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pochodzenie_ma_znaczenie/utils.dart';
import 'login_screen.dart';

class ProductScreen extends StatefulWidget {
  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  String? productInfo; //informacje o produkcie
  String? error; //błąd
  String? name; //nazwa produktu
  String? brand; //marka produktu
  String? country; //kraj produktu
  bool isFromUSA = false; //czy produkt pochodzi z USA

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String barcode = ModalRoute.of(context)?.settings.arguments as String; //pobranie kodu produktu
    _fetchProductData(barcode); //pobranie danych produktu
  }

  Future<void> _fetchProductData(String barcode) async {
    if (isTokenExpired(Auth.token)) { //sprawdzenie czy token jest ważny
      final refreshed = await Auth.refreshToken(); //odświeżenie tokenu
      if (!refreshed) { //jeśli token nie został odświeżony
        if (mounted) { //jeśli ekran jest nadal widoczny
          Navigator.pushReplacementNamed(context, '/login'); //przejście do ekranu logowania
        }
        return; //zakończenie funkcji
      }
    }
    final cached = await ProductCache.getProduct(barcode); //pobranie danych produktu z cache
    if (cached != null) { //jeśli dane są w cache
      name = cached['Name'] ?? 'Nieznany produkt'; //pobranie nazwy produktu
      brand = cached['Brand'] ?? 'Brak marki'; //pobranie marki produktu
      country = cached['Country'] ?? 'Brak kraju'; //pobranie kraju produktu
      isFromUSA = cached['IsFromUSA'] == true; //pobranie informacji czy produkt pochodzi z USA
      setState(() {}); //zaktualizowanie stanu
      return; //zakończenie funkcji
    }
    //final url = Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcode.json');
    final url = Uri.parse('https://boxpvp.top:8443/api/barcodeinfo?barcode=$barcode'); //pobranie danych produktu z API
    try { //pobranie danych produktu z API
      final response = await http.get( //pobranie danych produktu z API
          url,
          headers: { 'Authorization': 'Bearer ${Auth.token}' } //pobranie danych produktu z API
      );
      if (response.statusCode == 200) { //jeśli odpowiedź jest 200
        final data = json.decode(response.body); //pobranie danych produktu z API
        name = data['Name'] ?? 'Nieznany produkt'; //pobranie nazwy produktu
        brand = data['Brand'] ?? 'Brak marki'; //pobranie marki produktu
        country = data['Country'] ?? 'Brak kraju'; //pobranie kraju produktu
        isFromUSA = data['IsFromUSA'] == true; //pobranie informacji czy produkt pochodzi z USA
        NotificationUtils.showSuccessNotification(" name  brand  country"); //pokazanie powiadomienia
        await ProductCache.saveProduct(barcode, data); //zapisanie danych produktu do cache
        setState(() {}); //zaktualizowanie stanu
      } else {
        setState(() { //zaktualizowanie stanu
          error = "❌ Nie znaleziono produktu\nKod: $barcode"; //pokazanie błędu
        });
      }
    } catch (e) {
      setState(() { //zaktualizowanie stanu
        error = "⚠️ Błąd pobierania danych."; //pokazanie błędu
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold( //ekran
      appBar: AppBar(title: const Text('Szczegóły produktu')), //tytuł ekranu
      body: Stack( //stos elementów
        children: [ //elementy  
          // Tło
          Opacity( //przezroczystość
            opacity: 0.3,  // możesz dać 0.5 jak wolisz
            child: Image.asset( //obraz
              'assets/icon1.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          // Główna zawartość
          Center( //wyśrodkowanie
            child: Padding( //padding
              padding: const EdgeInsets.all(16.0), //padding
              child: error != null
                  ? Column( //kolumna
                mainAxisAlignment: MainAxisAlignment.center, //wyrównanie do środka
                children: [ //elementy
                  const Icon(Icons.error_outline, size: 60, color: Colors.red), //ikona błędu
                  const SizedBox(height: 16),
                  Text( //tekst
                    error!, //błąd
                    style: const TextStyle(fontSize: 16), //styling tekstu
                    textAlign: TextAlign.center, //wyrównanie do środka
                  ),
                ],
              ) //jeśli jest błąd
                  : name != null //jeśli jest nazwa produktu
                  ? Card( //kartka
                elevation: 4, //rzucenie cienia
                shape: RoundedRectangleBorder( //krawędzie zaokrąglone
                  borderRadius: BorderRadius.circular(16), //zaokrąglenie krawędzi
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0), //padding
                  child: Column( //kolumna
                    mainAxisSize: MainAxisSize.min, //główny rozmiar
                    crossAxisAlignment: CrossAxisAlignment.start, //wyrównanie do lewej
                    children: [
                      _buildDetailRow("🧾 Nazwa", name!), //budowanie wiersza
                      const SizedBox(height: 12), //odstęp
                      _buildDetailRow("🏷️ Marka", brand!), //budowanie wiersza
                      const SizedBox(height: 12), //odstęp
                      _buildDetailRow( //budowanie wiersza
                        "🌍 Kraj", //etykieta
                        country!, //wartość
                        textColor: isFromUSA ? Colors.red : null, //kolor tekstu
                        isBold: isFromUSA, //pogrubienie
                      ),
                      const SizedBox(height: 24), //odstęp
                      if (isFromUSA) //jeśli produkt pochodzi z USA
                        Container( //kontener
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), //padding
                          decoration: BoxDecoration( //dekoracja
                            color: Colors.red.shade50, //kolor tła
                            borderRadius: BorderRadius.circular(12), //zaokrąglenie krawędzi
                            border: Border.all(color: Colors.red), //krawędzie
                          ),
                          child: Row( //wiersz
                            children: const [ //elementy
                              Icon(Icons.warning_amber, color: Colors.red), //ikona ostrzeżenia
                              SizedBox(width: 12), //odstęp
                              Expanded( //rozszerzenie
                                child: Text( //tekst
                                  "Produkt pochodzi z USA!", //tekst
                                  style: TextStyle(color: Colors.red), //styling tekstu
                                ),
                              ), //rozszerzenie
                            ], //elementy
                          ), //wiersz
                        ), //kontener
                    ], //elementy
                  ), //kolumna
                ), //padding
              ) //kartka
                  : const CircularProgressIndicator(), //pasek ładowania
            ), //padding
          ), //wyśrodkowanie
        ], //elementy
      ), //stos elementów
    ); //ekran
  }


  Widget _buildDetailRow(String label, String value,
      {Color? textColor, bool isBold = false}) { //budowanie wiersza
    return Row( //wiersz
      crossAxisAlignment: CrossAxisAlignment.start, //wyrównanie do góry
      children: [ //elementy
        Text( //tekst
          "$label: ", //tekst
          style: const TextStyle(fontWeight: FontWeight.bold), //styling tekstu
        ),
        Expanded( //rozszerzenie
          child: Text( //tekst
            value, //tekst
            style: TextStyle(
              color: textColor, //kolor tekstu
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal, //pogrubienie
            ), //styling tekstu
          ), //rozszerzenie
        ), //elementy
      ], //wiersz
    ); //budowanie wiersza
  }


}
