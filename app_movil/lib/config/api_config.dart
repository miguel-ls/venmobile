import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _baseUrlDebug = 'http://172.16.50.152/personal/venmobile/backend/api.php'; // IP para desarrollo local
  static const String _baseUrlRelease = 'https://tu-dominio-de-produccion.com/api.php'; // URL para producción

  //static const String pbaseUrl = 'http://172.16.50.73/personal/venmobile/backend';

  static String get baseUrl {
    return kDebugMode ? _baseUrlDebug : _baseUrlRelease;
  }
}


class AppConfig {
  
}