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

  final TextEditingController _docController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  String? _estadoFilter = 'Todos';

  @override
  void initState() {
    super.initState();
    _clientesFuture = _clienteService.getClientes();
  }

  void _refreshClientes() {
    setState(() {
      _clientesFuture = _clienteService.getClientes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Clientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Nuevo Cliente',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ClienteEditScreen()),
              );
              if (result == true) {
                _refreshClientes();
              }
            },
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
                onChanged: (value) => setState(() {}),
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
                onChanged: (value) => setState(() {}),
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
                onChanged: (value) => setState(() {}),
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
                onChanged: (value) => setState(() {}),
              ),
            ),
            SizedBox(
              width: 150,
              child: DropdownButtonFormField<String>(
                value: _estadoFilter,
                decoration: const InputDecoration(
                  labelText: 'Todos los Estados',
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
          final clientes = snapshot.data!;
          final filteredClientes = clientes.where((cliente) {
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

          return ListView.builder(
            itemCount: filteredClientes.length,
            itemBuilder: (context, index) {
              final cliente = filteredClientes[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              cliente.nombresApellidos,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Chip(
                            label: Text(
                              cliente.estado,
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: cliente.estado == 'Activado'
                                ? Colors.green
                                : Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${cliente.tipoDocumento ?? 'N/A'}: ${cliente.numeroDocumento}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      if (cliente.email != null && cliente.email!.isNotEmpty) ...[
                        Text(
                          'Email: ${cliente.email}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                      ],
                      if (cliente.telefono != null && cliente.telefono!.isNotEmpty) ...[
                        Text(
                          'Teléfono: ${cliente.telefono}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                      ],
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
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
                                _refreshClientes();
                              }
                            },
                            tooltip: 'Editar',
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteCliente(context, cliente),
                            tooltip: 'Eliminar',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
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
                  _refreshClientes();
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
