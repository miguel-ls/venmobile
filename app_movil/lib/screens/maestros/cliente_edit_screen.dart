import 'package:app_movil/models/cliente.dart';
import 'package:app_movil/models/tipo_documento_identidad.dart';
import 'package:app_movil/services/cliente_service.dart';
import 'package:app_movil/services/tipo_documento_identidad_service.dart';
import 'package:flutter/material.dart';

class ClienteEditScreen extends StatefulWidget {
  final Cliente? cliente;

  const ClienteEditScreen({super.key, this.cliente});

  @override
  _ClienteEditScreenState createState() => _ClienteEditScreenState();
}

class _ClienteEditScreenState extends State<ClienteEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clienteService = ClienteService();
  final _tipoDocumentoIdentidadService = TipoDocumentoIdentidadService();

  late TextEditingController _numeroDocumentoController;
  late TextEditingController _nombresApellidosController;
  late TextEditingController _direccionController;
  late TextEditingController _codigoUbigeoController;
  late TextEditingController _emailController;
  late TextEditingController _telefonoController;

  int? _selectedTipoDocumento;
  String? _selectedEstado;
  bool _isLoading = false;
  late Future<List<TipoDocumentoIdentidad>> _tiposDocumentoFuture;

  @override
  void initState() {
    super.initState();
    _selectedTipoDocumento = widget.cliente?.idTipoDocumentoIdentidad;
    _selectedEstado = widget.cliente?.estado ?? 'Activado';

    _tiposDocumentoFuture =
        _tipoDocumentoIdentidadService.getTiposDocumentoIdentidad();
    _tiposDocumentoFuture.then((tipos) {
      if (_selectedTipoDocumento != null &&
          !tipos.any((tipo) => tipo.id == _selectedTipoDocumento)) {
        if (mounted) {
          setState(() {
            _selectedTipoDocumento = null;
          });
        }
      }
    });

    _numeroDocumentoController =
        TextEditingController(text: widget.cliente?.numeroDocumento ?? '');
    _nombresApellidosController =
        TextEditingController(text: widget.cliente?.nombresApellidos ?? '');
    _direccionController =
        TextEditingController(text: widget.cliente?.direccion ?? '');
    _codigoUbigeoController =
        TextEditingController(text: widget.cliente?.codigoUbigeo ?? '');
    _emailController = TextEditingController(text: widget.cliente?.email ?? '');
    _telefonoController =
        TextEditingController(text: widget.cliente?.telefono ?? '');
  }

  @override
  void dispose() {
    _numeroDocumentoController.dispose();
    _nombresApellidosController.dispose();
    _direccionController.dispose();
    _codigoUbigeoController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final cliente = Cliente(
          id: widget.cliente?.id ?? 0,
          idTipoDocumentoIdentidad: _selectedTipoDocumento!,
          numeroDocumento: _numeroDocumentoController.text,
          nombresApellidos: _nombresApellidosController.text,
          direccion: _direccionController.text,
          codigoUbigeo: _codigoUbigeoController.text,
          email: _emailController.text,
          telefono: _telefonoController.text,
          estado: _selectedEstado!,
        );

        if (widget.cliente == null) {
          await _clienteService.createCliente(cliente);
        } else {
          await _clienteService.updateCliente(cliente.id, cliente);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Cliente ${widget.cliente == null ? 'creado' : 'actualizado'} con éxito')),
        );
        Navigator.pop(context, true); // Return true to indicate success
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar cliente: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.cliente == null ? 'Crear Nuevo Cliente' : 'Editar Cliente'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Volver a Lista'),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDropdownTipoDocumento(),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                      _numeroDocumentoController, 'N° de Documento',
                      isRequired: true),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                      _nombresApellidosController, 'Nombres y Apellidos',
                      isRequired: true),
                  const SizedBox(height: 16),
                  _buildTextFormField(_direccionController, 'Dirección'),
                  const SizedBox(height: 16),
                  _buildTextFormField(_codigoUbigeoController, 'Código de Ubigeo'),
                  const SizedBox(height: 16),
                  _buildTextFormField(_emailController, 'Email',
                      isEmail: true),
                  const SizedBox(height: 16),
                  _buildTextFormField(_telefonoController, 'Teléfono'),
                  if (widget.cliente != null) ...[
                    const SizedBox(height: 16),
                    _buildDropdownEstado(),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(widget.cliente == null
                            ? 'Crear Cliente'
                            : 'Guardar Cambios'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownTipoDocumento() {
    return FutureBuilder<List<TipoDocumentoIdentidad>>(
      future: _tiposDocumentoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No se encontraron tipos de documento');
        }

        final tiposDocumento = snapshot.data!;

        return DropdownButtonFormField<int>(
          value: _selectedTipoDocumento,
          decoration: const InputDecoration(
            labelText: 'Tipo de Documento',
            border: OutlineInputBorder(),
          ),
          items: tiposDocumento.map((tipo) {
            return DropdownMenuItem<int>(
              value: tipo.id,
              child: Text(tipo.nombre),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedTipoDocumento = value;
            });
          },
          validator: (value) => value == null
              ? 'Por favor seleccione un tipo de documento'
              : null,
        );
      },
    );
  }

  Widget _buildDropdownEstado() {
    return DropdownButtonFormField<String>(
      value: _selectedEstado,
      decoration: const InputDecoration(
        labelText: 'Estado',
        border: OutlineInputBorder(),
      ),
      items: ['Activado', 'Desactivado'].map((estado) {
        return DropdownMenuItem<String>(
          value: estado,
          child: Text(estado),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedEstado = value;
        });
      },
      validator: (value) =>
          value == null ? 'Por favor seleccione un estado' : null,
    );
  }

  Widget _buildTextFormField(
      TextEditingController controller, String label,
      {bool isRequired = false, bool isEmail = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'Este campo es obligatorio';
        }
        if (isEmail && value != null && value.isNotEmpty) {
          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
          if (!emailRegex.hasMatch(value)) {
            return 'Por favor ingrese un correo válido';
          }
        }
        return null;
      },
    );
  }
}
