import 'package:app_movil/config/api_config.dart';
import 'package:app_movil/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

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

  @override
  void initState() {
    super.initState();
    _fetchCaptcha();
  }

  Future<void> _fetchCaptcha() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/captcha'));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _captcha = responseData['captcha'];
        });
      }
    } catch (e) {
      // Manejar error de carga del CAPTCHA
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final url = Uri.parse('${ApiConfig.baseUrl}/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': _usernameController.text,
          'password': _passwordController.text,
          'captcha': _captchaController.text,
        }),
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 200 && responseData['status'] == 'success') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } else {
        _showErrorDialog(responseData['message'] ?? 'Error desconocido');
        _fetchCaptcha(); // Recargar CAPTCHA en caso de error
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
                    child: Center(child: Text(_captcha.isEmpty ? '...' : _captcha)),
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
