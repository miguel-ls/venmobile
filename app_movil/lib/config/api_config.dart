import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _baseUrlDebug = 'http://192.168.1.100/app_movil_backend/api.php'; // IP para desarrollo local
  static const String _baseUrlRelease = 'https://tu-dominio-de-produccion.com/api.php'; // URL para producción

  static String get baseUrl {
    return kDebugMode ? _baseUrlDebug : _baseUrlRelease;
  }
}
