import 'dart:convert';
import 'package:app_movil/models/tipo_cambio_model.dart';
import 'package:app_movil/services/tipo_cambio_service.dart';
import 'package:flutter/material.dart';
import 'package:app_movil/screens/maestros/tipo_cambio_form_screen.dart';

class TipoCambioScreen extends StatefulWidget {
  const TipoCambioScreen({super.key});

  @override
  _TipoCambioScreenState createState() => _TipoCambioScreenState();
}

class _TipoCambioScreenState extends State<TipoCambioScreen> {
  late Future<List<TipoCambio>> futureTipoCambios;
  final TipoCambioService tipoCambioService = TipoCambioService();

  List<String> years = List<String>.generate(10, (int index) => (DateTime.now().year - index).toString());
  List<String> months = List<String>.generate(12, (int index) => (index + 1).toString().padLeft(2, '0'));

  String selectedYear = DateTime.now().year.toString();
  String selectedMonth = DateTime.now().month.toString().padLeft(2, '0');

  @override
  void initState() {
    super.initState();
    _loadTipoCambios();
  }

  void _loadTipoCambios() {
    setState(() {
      futureTipoCambios = tipoCambioService.getTipoCambios(year: selectedYear, month: selectedMonth);
    });
  }

  void _deleteTipoCambio(int id) async {
    try {
      await tipoCambioService.deleteTipoCambio(id);
      _loadTipoCambios();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete tipo cambio: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tipo de Cambio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TipoCambioFormScreen(),
                ),
              );
              _loadTipoCambios();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: FutureBuilder<List<TipoCambio>>(
              future: futureTipoCambios,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      TipoCambio tipoCambio = snapshot.data![index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text('Fecha: ${tipoCambio.fecha}'),
                          subtitle: Text('Compra: ${tipoCambio.compra} - Venta: ${tipoCambio.venta}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TipoCambioFormScreen(tipoCambio: tipoCambio),
                                    ),
                                  );
                                  _loadTipoCambios();
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  _deleteTipoCambio(tipoCambio.id!);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          DropdownButton<String>(
            value: selectedYear,
            onChanged: (String? newValue) {
              setState(() {
                selectedYear = newValue!;
                _loadTipoCambios();
              });
            },
            items: years.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          DropdownButton<String>(
            value: selectedMonth,
            onChanged: (String? newValue) {
              setState(() {
                selectedMonth = newValue!;
                _loadTipoCambios();
              });
            },
            items: months.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
