import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  ApiConstants._();

  static const String _directBaseUrl = 'https://api.deezer.com';

  // Deezer no manda Access-Control-Allow-Origin, así que Flutter Web no
  // puede llamarla directo desde el navegador (CORS). En desarrollo se usa
  // tool/cors_proxy.dart, que sí agrega esa cabecera. Android/Windows/iOS
  // no tienen ese problema porque no son peticiones de navegador.
  static const String _webProxyBaseUrl = 'http://localhost:8787';

  static String get baseUrl => kIsWeb ? _webProxyBaseUrl : _directBaseUrl;
}
