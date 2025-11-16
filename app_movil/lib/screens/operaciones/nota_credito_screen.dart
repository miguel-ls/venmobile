import 'package:flutter/material.dart';

class NotaCreditoScreen extends StatelessWidget {
  const NotaCreditoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nota de Crédito'),
      ),
      body: const Center(
        child: Text('Pantalla de Nota de Crédito'),
      ),
    );
  }
}
