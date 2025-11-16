import 'package:flutter/material.dart';

class TipoCambioScreen extends StatelessWidget {
  const TipoCambioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tipo de Cambio'),
      ),
      body: const Center(
        child: Text('Pantalla de Tipo de Cambio'),
      ),
    );
  }
}
