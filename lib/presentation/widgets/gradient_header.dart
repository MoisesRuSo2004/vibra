import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Fondo con degradado tipo Spotify (morado → fondo oscuro), fijo detrás
/// del contenido scrolleable. Se usa en Home, artista y álbum.
class GradientHeader extends StatelessWidget {
  final Widget child;
  final double height;

  const GradientHeader({super.key, required this.child, this.height = 280});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: height,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: AppColors.headerGradient,
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
