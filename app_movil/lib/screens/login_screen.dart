import 'dart:convert';
import 'package:app_movil/config/api_config.dart';
import 'package:app_movil/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _captchaController = TextEditingController();
  bool _isLoading = false;
  String _captcha = '';
  String? _sessionCookie; // Variable para guardar la cookie de sesión

  @override
  void initState() {
    super.initState();
    _fetchCaptcha();
  }

  // Función para extraer la cookie de la cabecera
  void _updateCookie(http.Response response) {
    String? rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      // Extraemos la parte relevante de la cookie (antes del primer ';')
      int index = rawCookie.indexOf(';');
      _sessionCookie = (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
  }

  Future<void> _fetchCaptcha() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/captcha'));
      if (response.statusCode == 200) {
        // Guardamos la cookie de la respuesta
        _updateCookie(response);
        
        final responseData = json.decode(response.body);
        setState(() {
          _captcha = responseData['captcha'];
        });
      }
    } catch (e) {
      _showErrorDialog('No se pudo cargar el CAPTCHA. Revisa la conexión con el servidor.');
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final url = Uri.parse('${ApiConfig.baseUrl}/login');
    
    // Preparamos las cabeceras para enviar la cookie
    final headers = {
      'Content-Type': 'application/json',
      if (_sessionCookie != null) 'Cookie': _sessionCookie!,
    };

    try {
      final response = await http.post(
        url,
        headers: headers, // Enviamos las cabeceras con la cookie
        body: json.encode({
          'username': _usernameController.text,
          'password': _passwordController.text,
          'captcha': _captchaController.text,
        }),
      );

      // La sesión puede actualizarse, así que guardamos la cookie de nuevo
      _updateCookie(response);

      final responseData = json.decode(response.body);
      if (response.statusCode == 200 && responseData['status'] == 'success') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } else {
        _showErrorDialog(responseData['message'] ?? 'Error desconocido');
        // Si el login falla, obtenemos un nuevo CAPTCHA (y una nueva sesión)
        _fetchCaptcha();
        _captchaController.clear();
      }
    } catch (e) {
      _showErrorDialog('Error de conexión.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[TextButton(child: Text('Ok'), onPressed: () => Navigator.of(ctx).pop())],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // El resto del método build se mantiene igual
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _captchaController,
                      decoration: InputDecoration(labelText: 'CAPTCHA'),
                      validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    width: 100,
                    height: 50,
                    color: Colors.grey[300],
                    child: Center(child: Text(_captcha.isEmpty ? '...' : _captcha, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: _fetchCaptcha,
                  ),
                ],
              ),
              SizedBox(height: 20),
              _isLoading ? CircularProgressIndicator() : ElevatedButton(onPressed: _login, child: Text('Login')),
            ],
          ),
        ),
      ),
    );
  }
}