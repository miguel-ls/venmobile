import 'package:flutter/material.dart';

class UsuariosPvScreen extends StatelessWidget {
  const UsuariosPvScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios por PV'),
      ),
      body: const Center(
        child: Text('Pantalla de Usuarios por PV'),
      ),
    );
  }
}
