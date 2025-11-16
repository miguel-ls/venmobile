import 'package:flutter/material.dart';

class PuntoVentaScreen extends StatelessWidget {
  const PuntoVentaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Punto de Venta'),
      ),
      body: const Center(
        child: Text('Pantalla de Punto de Venta'),
      ),
    );
  }
}
