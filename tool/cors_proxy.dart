import 'dart:io';

/// Proxy local de solo desarrollo: Deezer no manda la cabecera
/// Access-Control-Allow-Origin, así que Flutter Web no puede llamarla
/// directo. Este script reenvía cada request a Deezer y le agrega esa
/// cabecera a la respuesta antes de devolverla al navegador.
///
/// Uso: dart run tool/cors_proxy.dart
/// (dejarlo corriendo mientras se usa `flutter run -d chrome`)
const _targetHost = 'api.deezer.com';
const _port = 8787;

Future<void> main() async {
  final client = HttpClient();
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, _port);
  stdout.writeln('CORS proxy de Deezer escuchando en http://localhost:$_port');
  stdout.writeln('Solo para desarrollo. Ctrl+C para detener.');

  await for (final request in server) {
    _handle(request, client);
  }
}

Future<void> _handle(HttpRequest request, HttpClient client) async {
  request.response.headers
    ..add('Access-Control-Allow-Origin', '*')
    ..add('Access-Control-Allow-Headers', '*')
    ..add('Access-Control-Allow-Methods', 'GET, OPTIONS');

  if (request.method == 'OPTIONS') {
    request.response.statusCode = HttpStatus.noContent;
    await request.response.close();
    return;
  }

  final targetUri = Uri.https(_targetHost, request.uri.path, request.uri.queryParameters);

  try {
    final proxyRequest = await client.getUrl(targetUri);
    final proxyResponse = await proxyRequest.close();

    request.response.statusCode = proxyResponse.statusCode;
    final contentType = proxyResponse.headers.contentType;
    if (contentType != null) {
      request.response.headers.contentType = contentType;
    }
    await proxyResponse.pipe(request.response);
  } catch (e) {
    request.response.statusCode = HttpStatus.badGateway;
    request.response.write('Proxy error: $e');
    await request.response.close();
  }
}
