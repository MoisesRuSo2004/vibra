import '../models/album.dart';
import '../models/artist.dart';
import '../models/genre.dart';
import '../models/track.dart';
import '../services/music_api_service.dart';

/// Resultado ya tipado de un chart de Deezer (general o por género),
/// listo para alimentar el Home o la pantalla de un género.
class HomeFeed {
  final List<Track> recommendedTracks;
  final List<Artist> popularArtists;
  final List<Album> popularAlbums;

  const HomeFeed({
    required this.recommendedTracks,
    required this.popularArtists,
    required this.popularAlbums,
  });

  factory HomeFeed.fromChartJson(Map<String, dynamic> chart) {
    final tracks = (chart['tracks']['data'] as List<dynamic>)
        .map((e) => Track.fromJson(e as Map<String, dynamic>))
        .toList();
    final artists = (chart['artists']['data'] as List<dynamic>)
        .map((e) => Artist.fromJson(e as Map<String, dynamic>))
        .toList();
    final albums = (chart['albums']['data'] as List<dynamic>)
        .map((e) => Album.fromJson(e as Map<String, dynamic>))
        .toList();

    return HomeFeed(
      recommendedTracks: tracks,
      popularArtists: artists,
      popularAlbums: albums,
    );
  }
}

/// Punto único por el que la capa de presentación pide datos musicales.
/// Traduce las respuestas crudas del [MusicApiService] a los modelos
/// que el resto de la app necesita.
class MusicRepository {
  final MusicApiService _api;

  MusicRepository({MusicApiService? api}) : _api = api ?? MusicApiService();

  Future<HomeFeed> getHomeFeed() async {
    final chart = await _api.getChart();
    return HomeFeed.fromChartJson(chart);
  }

  Future<HomeFeed> getGenreFeed(int genreId) async {
    final chart = await _api.getChartByGenre(genreId);
    return HomeFeed.fromChartJson(chart);
  }

  Future<List<Genre>> getGenres() => _api.getGenres();

  Future<List<Track>> searchTracks(String query) => _api.searchTracks(query);

  Future<List<Artist>> searchArtists(String query) => _api.searchArtists(query);

  Future<Artist> getArtist(int artistId) => _api.getArtist(artistId);

  Future<List<Track>> getArtistTopTracks(int artistId) =>
      _api.getArtistTopTracks(artistId);

  Future<List<Album>> getArtistAlbums(int artistId) =>
      _api.getArtistAlbums(artistId);

  Future<Album> getAlbum(int albumId) => _api.getAlbum(albumId);

  Future<List<Track>> getAlbumTracks(int albumId) =>
      _api.getAlbumTracks(albumId);
}
