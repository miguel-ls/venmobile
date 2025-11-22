import 'dart:convert';
import 'package:app_movil/models/cliente.dart';
import 'package:http/http.dart' as http;
import 'package:app_movil/config/app_config.dart';
import 'package:app_movil/services/auth_service.dart';

class ClienteService {
  final String _baseUrl = AppConfig.apiUrl;
  final AuthService _authService = AuthService();

  Future<List<Cliente>> getClientes() async {
    final cookie = await _authService.getSessionCookie();
    final response = await http.get(
      Uri.parse('$_baseUrl/clientes'),
      headers: {'Cookie': cookie ?? ''},
    );

    if (response.statusCode == 200) {
      final List<dynamic> clienteJson = json.decode(response.body);
      return clienteJson.map((json) => Cliente.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load clientes');
    }
  }

  Future<Cliente> getCliente(int id) async {
    final cookie = await _authService.getSessionCookie();
    final response = await http.get(
      Uri.parse('$_baseUrl/clientes/$id'),
      headers: {'Cookie': cookie ?? ''},
    );

    if (response.statusCode == 200) {
      return Cliente.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load cliente');
    }
  }

  Future<Cliente> createCliente(Cliente cliente) async {
    final cookie = await _authService.getSessionCookie();
    final response = await http.post(
      Uri.parse('$_baseUrl/clientes'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': cookie ?? ''
      },
      body: json.encode(cliente.toJson()),
    );

    if (response.statusCode == 201) {
      return Cliente.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create cliente');
    }
  }

  Future<void> updateCliente(int id, Cliente cliente) async {
    final cookie = await _authService.getSessionCookie();
    final response = await http.put(
      Uri.parse('$_baseUrl/clientes/$id'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': cookie ?? ''
      },
      body: json.encode(cliente.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update cliente');
    }
  }

  Future<void> deleteCliente(int id) async {
    final cookie = await _authService.getSessionCookie();
    final response = await http.delete(
      Uri.parse('$_baseUrl/clientes/$id'),
      headers: {'Cookie': cookie ?? ''},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete cliente');
    }
  }
}
