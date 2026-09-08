class Artist {
  final int id;
  final String name;
  final String pictureMedium;
  final String pictureBig;
  final int nbAlbum;
  final int nbFan;

  const Artist({
    required this.id,
    required this.name,
    required this.pictureMedium,
    required this.pictureBig,
    this.nbAlbum = 0,
    this.nbFan = 0,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Desconocido',
      pictureMedium: json['picture_medium'] as String? ?? '',
      pictureBig: json['picture_big'] as String? ?? '',
      nbAlbum: json['nb_album'] as int? ?? 0,
      nbFan: json['nb_fan'] as int? ?? 0,
    );
  }
}
