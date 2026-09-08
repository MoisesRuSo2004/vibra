class Track {
  final int id;
  final String title;
  final int duration;
  final String preview;
  final int artistId;
  final String artistName;
  final String artistPicture;
  final int albumId;
  final String albumTitle;
  final String albumCover;

  const Track({
    required this.id,
    required this.title,
    required this.duration,
    required this.preview,
    this.artistId = 0,
    this.artistName = '',
    this.artistPicture = '',
    this.albumId = 0,
    this.albumTitle = '',
    this.albumCover = '',
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    final artist = json['artist'] as Map<String, dynamic>?;
    final album = json['album'] as Map<String, dynamic>?;
    // El endpoint de tracks de un álbum no repite la portada del álbum,
    // así se puede pasar como fallback desde la pantalla que ya la tiene.
    return Track(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Sin título',
      duration: json['duration'] as int? ?? 0,
      preview: json['preview'] as String? ?? '',
      artistId: artist?['id'] as int? ?? 0,
      artistName: artist?['name'] as String? ?? '',
      artistPicture: artist?['picture_medium'] as String? ?? '',
      albumId: album?['id'] as int? ?? 0,
      albumTitle: album?['title'] as String? ?? '',
      albumCover: album?['cover_medium'] as String? ?? '',
    );
  }

  String get durationLabel {
    final minutes = duration ~/ 60;
    final seconds = (duration % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
