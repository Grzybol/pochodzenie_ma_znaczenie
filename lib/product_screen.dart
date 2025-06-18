import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductScreen extends StatefulWidget {
  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  String? productInfo;
  String? error;
  String? name;
  String? brand;
  String? country;
  bool isFromUSA = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String barcode = ModalRoute.of(context)?.settings.arguments as String;
    _fetchProductData(barcode);
  }

  Future<void> _fetchProductData(String barcode) async {
    //final url = Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcode.json');
    final url = Uri.parse('https://boxpvp.top:8443/api/barcodeinfo?barcode=$barcode');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        name = data['Name'] ?? 'Nieznany produkt';
        brand = data['Brand'] ?? 'Brak marki';
        country = data['Country'] ?? 'Brak kraju';
        isFromUSA = data['IsFromUSA'] == true;

        setState(() {});
      } else {
        setState(() {
          error = "❌ Nie znaleziono produktu\nKod: $barcode";
        });
      }
    } catch (e) {
      setState(() {
        error = "⚠️ Błąd pobierania danych.";
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Szczegóły produktu')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: error != null
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                error!,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          )
              : name != null
              ? Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow("🧾 Nazwa", name!),
                  const SizedBox(height: 12),
                  _buildDetailRow("🏷️ Marka", brand!),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    "🌍 Kraj",
                    country!,
                    textColor: isFromUSA ? Colors.red : null,
                    isBold: isFromUSA,
                  ),
                  const SizedBox(height: 24),
                  if (isFromUSA)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.warning_amber, color: Colors.red),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Produkt pochodzi z USA!",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          )
              : const CircularProgressIndicator(),
        ),
      ),
    );
  }


  Widget _buildDetailRow(String label, String value,
      {Color? textColor, bool isBold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label: ",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: textColor,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }


}
