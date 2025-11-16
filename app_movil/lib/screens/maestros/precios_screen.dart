import 'package:flutter/material.dart';

class PreciosScreen extends StatelessWidget {
  const PreciosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Precios'),
      ),
      body: const Center(
        child: Text('Pantalla de Precios'),
      ),
    );
  }
}
