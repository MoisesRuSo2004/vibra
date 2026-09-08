import 'package:flutter/foundation.dart';

import '../data/models/album.dart';
import '../data/models/artist.dart';
import '../data/models/genre.dart';
import '../data/models/track.dart';
import '../data/repositories/music_repository.dart';
import 'view_state.dart';

/// Estado de la pantalla Home (equivalente al _loadAnimes() del profe,
/// pero alimentado por /chart en vez de una lista fija de IDs).
class MusicProvider extends ChangeNotifier {
  final MusicRepository _repository;

  MusicProvider({MusicRepository? repository})
    : _repository = repository ?? MusicRepository();

  // ---- Home ----
  ViewState homeState = ViewState.initial;
  String homeError = '';
  List<Track> recommendedTracks = [];
  List<Artist> popularArtists = [];
  List<Album> popularAlbums = [];

  Future<void> loadHome() async {
    homeState = ViewState.loading;
    homeError = '';
    notifyListeners();

    try {
      final feed = await _repository.getHomeFeed();
      recommendedTracks = feed.recommendedTracks;
      popularArtists = feed.popularArtists;
      popularAlbums = feed.popularAlbums;
      homeState = ViewState.success;
    } catch (e) {
      homeError = 'No se pudo cargar el contenido: $e';
      homeState = ViewState.error;
    }
    notifyListeners();
  }

  // ---- Búsqueda ----
  ViewState searchState = ViewState.initial;
  String searchError = '';
  String lastQuery = '';
  List<Track> trackResults = [];
  List<Artist> artistResults = [];

  Future<void> search(String query) async {
    lastQuery = query;

    if (query.trim().isEmpty) {
      searchState = ViewState.initial;
      trackResults = [];
      artistResults = [];
      notifyListeners();
      return;
    }

    searchState = ViewState.loading;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.searchTracks(query),
        _repository.searchArtists(query),
      ]);
      trackResults = results[0] as List<Track>;
      artistResults = results[1] as List<Artist>;

      searchState = (trackResults.isEmpty && artistResults.isEmpty)
          ? ViewState.empty
          : ViewState.success;
    } catch (e) {
      searchError = 'Error al buscar: $e';
      searchState = ViewState.error;
    }
    notifyListeners();
  }

  // ---- Detalle de artista ----
  ViewState artistDetailState = ViewState.initial;
  String artistDetailError = '';
  Artist? selectedArtist;
  List<Track> artistTopTracks = [];
  List<Album> artistAlbums = [];

  Future<void> loadArtistDetail(int artistId) async {
    artistDetailState = ViewState.loading;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getArtist(artistId),
        _repository.getArtistTopTracks(artistId),
        _repository.getArtistAlbums(artistId),
      ]);
      selectedArtist = results[0] as Artist;
      artistTopTracks = results[1] as List<Track>;
      artistAlbums = results[2] as List<Album>;
      artistDetailState = ViewState.success;
    } catch (e) {
      artistDetailError = 'No se pudo cargar el artista: $e';
      artistDetailState = ViewState.error;
    }
    notifyListeners();
  }

  // ---- Detalle de álbum ----
  ViewState albumDetailState = ViewState.initial;
  String albumDetailError = '';
  Album? selectedAlbum;
  List<Track> albumTracks = [];

  Future<void> loadAlbumDetail(int albumId) async {
    albumDetailState = ViewState.loading;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getAlbum(albumId),
        _repository.getAlbumTracks(albumId),
      ]);
      selectedAlbum = results[0] as Album;
      albumTracks = results[1] as List<Track>;
      albumDetailState = ViewState.success;
    } catch (e) {
      albumDetailError = 'No se pudo cargar el álbum: $e';
      albumDetailState = ViewState.error;
    }
    notifyListeners();
  }

  // ---- Géneros (pantalla Explorar dentro de Buscar) ----
  ViewState genresState = ViewState.initial;
  List<Genre> genres = [];

  Future<void> loadGenres() async {
    if (genresState != ViewState.initial) return;
    genresState = ViewState.loading;
    notifyListeners();

    try {
      genres = await _repository.getGenres();
      genresState = ViewState.success;
    } catch (e) {
      genresState = ViewState.error;
    }
    notifyListeners();
  }

  // ---- Detalle de género ----
  ViewState genreDetailState = ViewState.initial;
  String genreDetailError = '';
  String selectedGenreName = '';
  List<Track> genreTracks = [];
  List<Artist> genreArtists = [];
  List<Album> genreAlbums = [];

  Future<void> loadGenreDetail(Genre genre) async {
    selectedGenreName = genre.name;
    genreDetailState = ViewState.loading;
    notifyListeners();

    try {
      final feed = await _repository.getGenreFeed(genre.id);
      genreTracks = feed.recommendedTracks;
      genreArtists = feed.popularArtists;
      genreAlbums = feed.popularAlbums;
      genreDetailState = ViewState.success;
    } catch (e) {
      genreDetailError = 'No se pudo cargar el género: $e';
      genreDetailState = ViewState.error;
    }
    notifyListeners();
  }
}
