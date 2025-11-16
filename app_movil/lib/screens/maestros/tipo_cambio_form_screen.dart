import 'dart:convert';
import 'package:app_movil/models/tipo_cambio_model.dart';
import 'package:app_movil/config/api_config.dart';
import 'package:app_movil/services/auth_service.dart';
import 'package:app_movil/services/tipo_cambio_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class TipoCambioFormScreen extends StatefulWidget {
  final TipoCambio? tipoCambio;

  const TipoCambioFormScreen({super.key, this.tipoCambio});

  @override
  _TipoCambioFormScreenState createState() => _TipoCambioFormScreenState();
}

class _TipoCambioFormScreenState extends State<TipoCambioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TipoCambioService tipoCambioService = TipoCambioService();

  late TextEditingController _fechaController;
  late TextEditingController _compraController;
  late TextEditingController _ventaController;
  late TextEditingController _monedaController;

  @override
  void initState() {
    super.initState();
    _fechaController = TextEditingController(text: widget.tipoCambio?.fecha ?? DateFormat('yyyy-MM-dd').format(DateTime.now()));
    _compraController = TextEditingController(text: widget.tipoCambio?.compra.toString() ?? '');
    _ventaController = TextEditingController(text: widget.tipoCambio?.venta.toString() ?? '');
    _monedaController = TextEditingController(text: widget.tipoCambio?.moneda ?? 'USD');
  }

  @override
  void dispose() {
    _fechaController.dispose();
    _compraController.dispose();
    _ventaController.dispose();
    _monedaController.dispose();
    super.dispose();
  }

  void _fetchFromSunat() async {
    final fecha = _fechaController.text;
    final url = '${ApiConfig.baseUrl}/sunat_tipo_cambio?fecha=$fecha';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Cookie': AuthService().sessionCookie ?? '',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _compraController.text = data['compra'].toString();
          _ventaController.text = data['venta'].toString();
        });
      } else {
        throw Exception('Failed to load data from SUNAT');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching from SUNAT: $e')),
      );
    }
  }

  void _saveTipoCambio() async {
    if (_formKey.currentState!.validate()) {
      final tipoCambio = TipoCambio(
        id: widget.tipoCambio?.id,
        fecha: _fechaController.text,
        compra: double.parse(_compraController.text),
        venta: double.parse(_ventaController.text),
        moneda: _monedaController.text,
      );

      try {
        if (widget.tipoCambio == null) {
          await tipoCambioService.createTipoCambio(tipoCambio);
        } else {
          await tipoCambioService.updateTipoCambio(tipoCambio.id!, tipoCambio);
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save tipo cambio: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tipoCambio == null ? 'Crear Tipo de Cambio' : 'Editar Tipo de Cambio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _fechaController,
                decoration: const InputDecoration(labelText: 'Fecha'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a date';
                  }
                  return null;
                },
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _fechaController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                    });
                  }
                },
              ),
              TextFormField(
                controller: _compraController,
                decoration: const InputDecoration(labelText: 'Compra'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a value';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ventaController,
                decoration: const InputDecoration(labelText: 'Venta'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a value';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _monedaController,
                decoration: const InputDecoration(labelText: 'Moneda'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a currency';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchFromSunat,
                child: const Text('SUNAT'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _saveTipoCambio,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
