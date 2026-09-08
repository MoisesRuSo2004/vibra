import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../models/album.dart';
import '../models/artist.dart';
import '../models/genre.dart';
import '../models/track.dart';

/// Envuelve las peticiones HTTP crudas a la API pública de Deezer.
/// No conoce Provider ni el estado de la UI: solo pide JSON y devuelve modelos.
class MusicApiService {
  final http.Client _client;

  MusicApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> _getJson(String path) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Error ${response.statusCode} al consultar Deezer');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (decoded.containsKey('error')) {
      throw Exception(
        decoded['error']['message'] ?? 'Error desconocido de Deezer',
      );
    }
    return decoded;
  }

  /// Portada del Home: mezcla de tracks, álbumes y artistas populares.
  Future<Map<String, dynamic>> getChart() => _getJson('/chart');

  /// Mismo formato que getChart(), pero filtrado por género (pantalla Explorar).
  Future<Map<String, dynamic>> getChartByGenre(int genreId) =>
      _getJson('/chart/$genreId');

  Future<List<Genre>> getGenres() async {
    final json = await _getJson('/genre');
    final data = json['data'] as List<dynamic>;
    return data
        .map((e) => Genre.fromJson(e as Map<String, dynamic>))
        // id 0 es "Todos", ya cubierto por el chart general del Home.
        .where((g) => g.id != 0)
        .toList();
  }

  Future<List<Track>> searchTracks(String query, {int limit = 25}) async {
    final json = await _getJson(
      '/search?q=${Uri.encodeQueryComponent(query)}&limit=$limit',
    );
    final data = json['data'] as List<dynamic>;
    return data.map((e) => Track.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Artist>> searchArtists(String query, {int limit = 10}) async {
    final json = await _getJson(
      '/search/artist?q=${Uri.encodeQueryComponent(query)}&limit=$limit',
    );
    final data = json['data'] as List<dynamic>;
    return data.map((e) => Artist.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Artist> getArtist(int artistId) async {
    final json = await _getJson('/artist/$artistId');
    return Artist.fromJson(json);
  }

  Future<List<Track>> getArtistTopTracks(int artistId, {int limit = 10}) async {
    final json = await _getJson('/artist/$artistId/top?limit=$limit');
    final data = json['data'] as List<dynamic>;
    return data.map((e) => Track.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Album>> getArtistAlbums(int artistId) async {
    final json = await _getJson('/artist/$artistId/albums');
    final data = json['data'] as List<dynamic>;
    return data.map((e) => Album.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Album> getAlbum(int albumId) async {
    final json = await _getJson('/album/$albumId');
    return Album.fromJson(json);
  }

  Future<List<Track>> getAlbumTracks(int albumId) async {
    final json = await _getJson('/album/$albumId/tracks');
    final data = json['data'] as List<dynamic>;
    return data.map((e) => Track.fromJson(e as Map<String, dynamic>)).toList();
  }
}
