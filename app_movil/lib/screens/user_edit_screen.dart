import 'dart:convert';
import 'package:app_movil/config/api_config.dart';
import 'package:app_movil/models/profile.dart';
import 'package:app_movil/models/user.dart';
import 'package:app_movil/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserEditScreen extends StatefulWidget {
  final User? user;

  const UserEditScreen({super.key, this.user});

  @override
  _UserEditScreenState createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<UserEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  int? _selectedProfileId;
  late Future<List<Profile>> _profilesFuture;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user?.username ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _passwordController = TextEditingController();
    _selectedProfileId = widget.user?.profileId;
    _profilesFuture = _fetchProfiles();
  }

  Future<List<Profile>> _fetchProfiles() async {
    final headers = {
      'Content-Type': 'application/json',
      if (_authService.sessionCookie != null) 'Cookie': _authService.sessionCookie!,
    };
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/profiles'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((p) => Profile.fromJson(p)).toList();
    } else {
      throw Exception('Failed to load profiles');
    }
  }

  Future<void> _saveUser() async {
    if (_formKey.currentState!.validate()) {
      final url = widget.user == null
          ? Uri.parse('${ApiConfig.baseUrl}/users')
          : Uri.parse('${ApiConfig.baseUrl}/users/${widget.user!.id}');

      final body = {
        'username': _usernameController.text,
        'email': _emailController.text,
        'profile_id': _selectedProfileId,
      };
      if (widget.user == null) {
        body['password'] = _passwordController.text;
      }

      final headers = {
        'Content-Type': 'application/json',
        if (_authService.sessionCookie != null) 'Cookie': _authService.sessionCookie!,
      };

      final response = await (widget.user == null
          ? http.post(url, headers: headers, body: json.encode(body))
          : http.put(url, headers: headers, body: json.encode(body)));

      if (response.statusCode == 201 || response.statusCode == 200) {
        Navigator.pop(context);
      } else {
        throw Exception('Failed to save user');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user == null ? 'Nuevo Usuario' : 'Editar Usuario'),
      ),
      body: SingleChildScrollView(
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
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre de usuario',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 16.0),
                  if (widget.user == null)
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      obscureText: true,
                      validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                    ),
                  const SizedBox(height: 16.0),
                  FutureBuilder<List<Profile>>(
                    future: _profilesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('No se encontraron perfiles.');
                      }
                      return DropdownButtonFormField<int>(
                        value: _selectedProfileId,
                        items: snapshot.data!.map((profile) {
                          return DropdownMenuItem<int>(
                            value: profile.id,
                            child: Text(profile.name),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedProfileId = value),
                        decoration: InputDecoration(
                          labelText: 'Perfil',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                        validator: (value) => value == null ? 'Campo requerido' : null,
                      );
                    },
                  ),
                  const SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: _saveUser,
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
