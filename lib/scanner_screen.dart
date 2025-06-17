import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Skanuj kod")),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              onDetect: (barcode) {
                if (barcode.barcodes.isNotEmpty) {
                  final code = barcode.barcodes.first.rawValue;
                  if (code != null) {
                    Navigator.pushNamed(
                      context,
                      '/product',
                      arguments: code,
                    );
                  }
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/product',
                  arguments: "5901234567890", // przykładowy kod
                );
              },
              child: Text("Testuj bez skanera"),
            ),
          )
        ],
      ),
    );
  }
}
