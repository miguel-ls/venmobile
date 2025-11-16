import 'dart:convert';
import 'dart:typed_data';
import 'package:app_movil/config/api_config.dart';
import 'package:app_movil/screens/home_screen.dart';
import 'package:app_movil/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  final _authService = AuthService();
  bool _isLoading = false;
  Uint8List? _captcha;

  @override
  void initState() {
    super.initState();
    _fetchCaptcha();
  }

  void _updateCookie(http.Response response) {
    String? rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      _authService.setSessionCookie((index == -1) ? rawCookie : rawCookie.substring(0, index));
    }
  }

  Future<void> _fetchCaptcha() async {
    try {
      final headers = {
        if (_authService.sessionCookie != null) 'Cookie': _authService.sessionCookie!,
      };
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/captcha'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        _updateCookie(response);
        setState(() {
          _captcha = response.bodyBytes;
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
    final headers = {
      'Content-Type': 'application/json',
      if (_authService.sessionCookie != null) 'Cookie': _authService.sessionCookie!,
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode({
          'username': _usernameController.text,
          'password': _passwordController.text,
          'captcha': _captchaController.text,
        }),
      );

      _updateCookie(response);

      final responseData = json.decode(response.body);
      if (response.statusCode == 200 && responseData['status'] == 'success') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
      } else {
        _showErrorDialog(responseData['message'] ?? 'Error desconocido');
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
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[TextButton(child: const Text('Ok'), onPressed: () => Navigator.of(ctx).pop())],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const FlutterLogo(size: 100.0),
                  const SizedBox(height: 48.0),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Usuario',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _captchaController,
                          decoration: const InputDecoration(
                            labelText: 'CAPTCHA',
                            prefixIcon: Icon(Icons.vpn_key),
                          ),
                          validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 120,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: _captcha != null
                            ? Image.memory(_captcha!, gaplessPlayback: true)
                            : const Center(child: CircularProgressIndicator()),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _fetchCaptcha,
                        tooltip: 'Refrescar CAPTCHA',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _login,
                          child: const Text('Iniciar Sesión'),
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
