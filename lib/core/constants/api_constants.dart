import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  ApiConstants._();

  static const String _directBaseUrl = 'https://api.deezer.com';

  // Deezer no manda Access-Control-Allow-Origin, así que Flutter Web no
  // puede llamarla directo desde el navegador (CORS). En desarrollo se usa
  // tool/cors_proxy.dart, que sí agrega esa cabecera. Android/Windows/iOS
  // no tienen ese problema porque no son peticiones de navegador.
  //
  // En producción (Vercel) el proxy es la función serverless en
  // deploy/web/api/deezer/, servida desde el mismo origen que la app —
  // por eso el build de producción pasa "/api/deezer" vía --dart-define
  // (ver deploy/web/build_and_deploy.sh). Sin ese flag, el valor por
  // defecto sigue siendo localhost:8787 para no romper `flutter run -d chrome`.
  static const String _webProxyBaseUrl = String.fromEnvironment(
    'DEEZER_PROXY_BASE_URL',
    defaultValue: 'http://localhost:8787',
  );

  static String get baseUrl => kIsWeb ? _webProxyBaseUrl : _directBaseUrl;
}
