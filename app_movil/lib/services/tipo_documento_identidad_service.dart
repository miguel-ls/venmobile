import 'dart:convert';
import 'package:app_movil/models/tipo_documento_identidad.dart';
import 'package:http/http.dart' as http;
import 'package:app_movil/config/app_config.dart';
import 'package:app_movil/services/auth_service.dart';

class TipoDocumentoIdentidadService {
  final String _baseUrl = AppConfig.apiUrl;
  final AuthService _authService = AuthService();

  Future<List<TipoDocumentoIdentidad>> getTiposDocumentoIdentidad() async {
    final cookie = await _authService.getSessionCookie();
    final response = await http.get(
      Uri.parse('$_baseUrl/tipos_documento_identidad'),
      headers: {'Cookie': cookie ?? ''},
    );

    if (response.statusCode == 200) {
      final List<dynamic> tipoJson = json.decode(response.body);
      return tipoJson
          .map((json) => TipoDocumentoIdentidad.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load tipos documento identidad');
    }
  }
}
