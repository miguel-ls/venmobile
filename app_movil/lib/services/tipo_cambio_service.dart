import 'dart:convert';
import 'package:app_movil/config/app_config.dart';
import 'package:app_movil/models/tipo_cambio_model.dart';
import 'package:app_movil/services/auth_service.dart';
import 'package:http/http.dart' as http;

class TipoCambioService {
  final String _baseUrl = '${AppConfig.baseUrl}/api.php/tipo_cambio';
  final _authService = AuthService();

  Future<List<TipoCambio>> getTipoCambios({required String year, required String month}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl?year=$year&month=$month'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': _authService.sessionCookie ?? '',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => TipoCambio.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load tipo cambios');
    }
  }

  Future<TipoCambio> createTipoCambio(TipoCambio tipoCambio) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': _authService.sessionCookie ?? '',
      },
      body: jsonEncode(tipoCambio.toJson()),
    );

    if (response.statusCode == 201) {
      return TipoCambio.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create tipo cambio');
    }
  }

  Future<void> updateTipoCambio(int id, TipoCambio tipoCambio) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': _authService.sessionCookie ?? '',
      },
      body: jsonEncode(tipoCambio.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update tipo cambio');
    }
  }

  Future<void> deleteTipoCambio(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': _authService.sessionCookie ?? '',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete tipo cambio');
    }
  }
}
