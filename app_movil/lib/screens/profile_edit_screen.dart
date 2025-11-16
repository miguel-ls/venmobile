import 'dart:convert';
import 'package:app_movil/config/api_config.dart';
import 'package:app_movil/models/profile.dart';
import 'package:app_movil/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfileEditScreen extends StatefulWidget {
  final Profile? profile;

  const ProfileEditScreen({super.key, this.profile});

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile?.name ?? '');
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final url = widget.profile == null
          ? Uri.parse('${ApiConfig.baseUrl}/profiles')
          : Uri.parse('${ApiConfig.baseUrl}/profiles/${widget.profile!.id}');

      final body = {'name': _nameController.text};
      final headers = {
        'Content-Type': 'application/json',
        if (_authService.sessionCookie != null) 'Cookie': _authService.sessionCookie!,
      };

      final response = await (widget.profile == null
          ? http.post(url, headers: headers, body: json.encode(body))
          : http.put(url, headers: headers, body: json.encode(body)));

      if (response.statusCode == 201 || response.statusCode == 200) {
        Navigator.pop(context);
      } else {
        throw Exception('Failed to save profile');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.profile == null ? 'Nuevo Perfil' : 'Editar Perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre del Perfil',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text('Guardar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
