import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../data/models/genre.dart';

/// Deezer no trae portadas reales por género, así que en vez de un
/// placeholder repetido se usa una tarjeta de color sólido con el nombre,
/// como el "Explorar" real de Spotify.
const List<Color> _genrePalette = [
  Color(0xFF2D9CFF),
  Color(0xFF7C5CFC),
  Color(0xFFE0559A),
  Color(0xFF1ED760),
  Color(0xFFFF8A3D),
  Color(0xFF4E3998),
  Color(0xFF00C2A8),
  Color(0xFFE94B3C),
];

class GenreCard extends StatelessWidget {
  final Genre genre;
  final int index;

  const GenreCard({super.key, required this.genre, required this.index});

  @override
  Widget build(BuildContext context) {
    final color = _genrePalette[index % _genrePalette.length];

    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, AppRoutes.genreDetail, arguments: genre),
      child: Container(
        height: 90,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.bottomLeft,
        child: Text(
          genre.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
