import 'dart:convert';
import 'package:app_movil/config/api_config.dart';
import 'package:app_movil/models/profile.dart';
import 'package:app_movil/models/user.dart';
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
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/profiles'));
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

      final response = await (widget.user == null
          ? http.post(url, headers: {'Content-Type': 'application/json'}, body: json.encode(body))
          : http.put(url, headers: {'Content-Type': 'application/json'}, body: json.encode(body)));

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Nombre de usuario'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              if (widget.user == null)
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                  validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                ),
              FutureBuilder<List<Profile>>(
                future: _profilesFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  return DropdownButtonFormField<int>(
                    initialValue: _selectedProfileId,
                    items: snapshot.data!.map((profile) {
                      return DropdownMenuItem<int>(
                        value: profile.id,
                        child: Text(profile.name),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedProfileId = value),
                    decoration: InputDecoration(labelText: 'Perfil'),
                    validator: (value) => value == null ? 'Campo requerido' : null,
                  );
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _saveUser, child: Text('Guardar')),
            ],
          ),
        ),
      ),
    );
  }
}
