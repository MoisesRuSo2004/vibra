import 'package:flutter/foundation.dart';

import '../data/models/track.dart';

/// Estado local de favoritos (en memoria, por sesión). Es el ejemplo de
/// "estado propio de la app" que no depende de la API.
class FavoritesProvider extends ChangeNotifier {
  final Map<int, Track> _favorites = {};

  List<Track> get favorites => _favorites.values.toList(growable: false);

  bool isFavorite(int trackId) => _favorites.containsKey(trackId);

  void toggleFavorite(Track track) {
    if (_favorites.containsKey(track.id)) {
      _favorites.remove(track.id);
    } else {
      _favorites[track.id] = track;
    }
    notifyListeners();
  }
}
