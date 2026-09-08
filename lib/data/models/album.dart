class Album {
  final int id;
  final String title;
  final String coverMedium;
  final String coverBig;
  final String artistName;
  final int nbTracks;
  final String releaseDate;

  const Album({
    required this.id,
    required this.title,
    required this.coverMedium,
    required this.coverBig,
    this.artistName = '',
    this.nbTracks = 0,
    this.releaseDate = '',
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Sin título',
      coverMedium: json['cover_medium'] as String? ?? '',
      coverBig: json['cover_big'] as String? ?? '',
      artistName:
          (json['artist'] as Map<String, dynamic>?)?['name'] as String? ?? '',
      nbTracks: json['nb_tracks'] as int? ?? 0,
      releaseDate: json['release_date'] as String? ?? '',
    );
  }
}
