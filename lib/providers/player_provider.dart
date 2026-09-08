import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../data/models/track.dart';

enum TrackRepeatMode { off, all, one }

const int _maxRecentlyPlayed = 10;

/// Controla la reproducción del preview (30s) del track actual y expone
/// el estado para que el MiniPlayer y la pantalla de Reproductor lo compartan.
/// También lleva el historial de "escuchado recientemente" para el Home,
/// porque este es el único lugar por el que pasa toda reproducción sin
/// importar desde qué pantalla se disparó.
class PlayerProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Random _random = Random();

  Track? currentTrack;
  List<Track> _queue = [];
  int _queueIndex = -1;
  final List<Track> _recentlyPlayed = [];

  bool isShuffleOn = false;
  TrackRepeatMode repeatMode = TrackRepeatMode.off;

  PlayerState playerState = PlayerState.stopped;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;

  PlayerProvider() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      playerState = state;
      notifyListeners();
    });
    _audioPlayer.onPositionChanged.listen((p) {
      position = p;
      notifyListeners();
    });
    _audioPlayer.onDurationChanged.listen((d) {
      duration = d;
      notifyListeners();
    });
    _audioPlayer.onPlayerComplete.listen((_) => _onTrackComplete());
  }

  bool get isPlaying => playerState == PlayerState.playing;

  List<Track> get recentlyPlayed => List.unmodifiable(_recentlyPlayed);

  Future<void> playTrack(Track track, {List<Track>? queue}) async {
    if (queue != null) {
      _queue = queue;
      _queueIndex = queue.indexWhere((t) => t.id == track.id);
    }

    if (track.preview.isEmpty) {
      return;
    }

    currentTrack = track;
    _registerRecentlyPlayed(track);
    notifyListeners();
    await _audioPlayer.stop();
    await _audioPlayer.play(UrlSource(track.preview));
  }

  void _registerRecentlyPlayed(Track track) {
    _recentlyPlayed.removeWhere((t) => t.id == track.id);
    _recentlyPlayed.insert(0, track);
    if (_recentlyPlayed.length > _maxRecentlyPlayed) {
      _recentlyPlayed.removeLast();
    }
  }

  Future<void> togglePlayPause() async {
    if (currentTrack == null) return;
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  void toggleShuffle() {
    isShuffleOn = !isShuffleOn;
    notifyListeners();
  }

  void cycleRepeatMode() {
    repeatMode = switch (repeatMode) {
      TrackRepeatMode.off => TrackRepeatMode.all,
      TrackRepeatMode.all => TrackRepeatMode.one,
      TrackRepeatMode.one => TrackRepeatMode.off,
    };
    notifyListeners();
  }

  Future<void> seek(Duration to) => _audioPlayer.seek(to);

  Future<void> _onTrackComplete() async {
    if (repeatMode == TrackRepeatMode.one && currentTrack != null) {
      await playTrack(currentTrack!);
      return;
    }
    await playNext();
  }

  Future<void> playNext() async {
    if (_queue.isEmpty || _queueIndex == -1) return;

    if (isShuffleOn && _queue.length > 1) {
      int nextIndex;
      do {
        nextIndex = _random.nextInt(_queue.length);
      } while (nextIndex == _queueIndex);
      _queueIndex = nextIndex;
      await playTrack(_queue[_queueIndex]);
      return;
    }

    if (_queueIndex + 1 < _queue.length) {
      _queueIndex++;
      await playTrack(_queue[_queueIndex]);
    } else if (repeatMode == TrackRepeatMode.all) {
      _queueIndex = 0;
      await playTrack(_queue[_queueIndex]);
    }
  }

  Future<void> playPrevious() async {
    if (_queue.isEmpty || _queueIndex == -1) return;
    if (_queueIndex - 1 >= 0) {
      _queueIndex--;
      await playTrack(_queue[_queueIndex]);
    } else if (repeatMode == TrackRepeatMode.all) {
      _queueIndex = _queue.length - 1;
      await playTrack(_queue[_queueIndex]);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
