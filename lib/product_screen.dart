import 'package:flutter/material.dart';

class ProductScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String barcode = ModalRoute.of(context)?.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(title: Text('Szczegóły produktu')),
      body: Center(
        child: Text('Kod kreskowy: $barcode'),
      ),
    );
  }
}
