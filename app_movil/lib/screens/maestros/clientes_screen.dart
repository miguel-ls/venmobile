import 'package:app_movil/models/cliente.dart';
import 'package:app_movil/services/cliente_service.dart';
import 'package:flutter/material.dart';

import 'cliente_edit_screen.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  _ClientesScreenState createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final ClienteService _clienteService = ClienteService();
  late Future<List<Cliente>> _clientesFuture;
  List<Cliente> _clientes = [];
  List<Cliente> _filteredClientes = [];

  final TextEditingController _docController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  String? _estadoFilter = 'Todos';

  @override
  void initState() {
    super.initState();
    _loadClientes();
  }

  void _loadClientes() {
    _clientesFuture = _clienteService.getClientes();
    _clientesFuture.then((clientes) {
      setState(() {
        _clientes = clientes;
        _filteredClientes = clientes;
      });
    });
  }

  void _filterClientes() {
    setState(() {
      _filteredClientes = _clientes.where((cliente) {
        final docMatch = cliente.numeroDocumento
            .toLowerCase()
            .contains(_docController.text.toLowerCase());
        final nombreMatch = cliente.nombresApellidos
            .toLowerCase()
            .contains(_nombreController.text.toLowerCase());
        final emailMatch = (cliente.email ?? '')
            .toLowerCase()
            .contains(_emailController.text.toLowerCase());
        final telefonoMatch = (cliente.telefono ?? '')
            .toLowerCase()
            .contains(_telefonoController.text.toLowerCase());
        final estadoMatch = _estadoFilter == 'Todos' ||
            cliente.estado.toLowerCase() == _estadoFilter!.toLowerCase();
        return docMatch &&
            nombreMatch &&
            emailMatch &&
            telefonoMatch &&
            estadoMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Clientes'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ClienteEditScreen()),
                );
                if (result == true) {
                  _loadClientes();
                }
              },
              child: const Text('Nuevo Cliente'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildFilterSection(),
            const SizedBox(height: 16),
            Expanded(child: _buildClientesList()),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 150,
              child: TextField(
                controller: _docController,
                decoration: const InputDecoration(
                  labelText: 'Filtrar por N° Doc',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (value) => _filterClientes(),
              ),
            ),
            SizedBox(
              width: 150,
              child: TextField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Filtrar por Nombre',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (value) => _filterClientes(),
              ),
            ),
            SizedBox(
              width: 150,
              child: TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Filtrar por Email',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (value) => _filterClientes(),
              ),
            ),
            SizedBox(
              width: 150,
              child: TextField(
                controller: _telefonoController,
                decoration: const InputDecoration(
                  labelText: 'Filtrar por Teléfono',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (value) => _filterClientes(),
              ),
            ),
            SizedBox(
              width: 150,
              child: DropdownButtonFormField<String>(
                value: _estadoFilter,
                decoration: const InputDecoration(
                  labelText: 'Todos los Estad',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: ['Todos', 'Activado', 'Desactivado']
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _estadoFilter = value;
                    _filterClientes();
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientesList() {
    return FutureBuilder<List<Cliente>>(
      future: _clientesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No se encontraron clientes.'));
        } else {
          return Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Tipo Doc.')),
                  DataColumn(label: Text('N° Documento')),
                  DataColumn(label: Text('Nombres y Apellidos')),
                  DataColumn(label: Text('Dirección')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Teléfono')),
                  DataColumn(label: Text('Estado')),
                  DataColumn(label: Text('Acciones')),
                ],
                rows: _filteredClientes.map((cliente) {
                  return DataRow(
                    cells: [
                      DataCell(Text(cliente.tipoDocumento ?? '')),
                      DataCell(Text(cliente.numeroDocumento)),
                      DataCell(Text(cliente.nombresApellidos)),
                      DataCell(Text(cliente.direccion ?? '')),
                      DataCell(Text(cliente.email ?? '')),
                      DataCell(Text(cliente.telefono ?? '')),
                      DataCell(
                        Chip(
                          label: Text(
                            cliente.estado,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: cliente.estado == 'Activado'
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      DataCell(
                        Row(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.yellow),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ClienteEditScreen(
                                      cliente: cliente,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  _loadClientes();
                                }
                              },
                              child: const Text('Editar'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              onPressed: () => _deleteCliente(context, cliente),
                              child: const Text('Eliminar'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        }
      },
    );
  }

  void _deleteCliente(BuildContext context, Cliente cliente) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text(
              '¿Está seguro de que desea eliminar a ${cliente.nombresApellidos}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Eliminar'),
              onPressed: () async {
                try {
                  await _clienteService.deleteCliente(cliente.id);
                  Navigator.of(context).pop();
                  _loadClientes();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Cliente eliminado correctamente')),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al eliminar cliente: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
