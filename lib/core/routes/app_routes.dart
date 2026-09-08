import 'package:flutter/material.dart';

/// Nombres de ruta y transiciones reutilizables por el Navigator anidado
/// de AppShell (ver presentation/screens/app_shell.dart), que es quien
/// realmente decide qué pantalla mostrar dentro de la barra inferior.
class AppRoutes {
  AppRoutes._();

  static const String artistDetail = '/artist';
  static const String albumDetail = '/album';
  static const String genreDetail = '/genre';
  static const String player = '/player';

  /// Detalle de artista/álbum: entra con un ligero zoom-in + fade, como si
  /// te acercaras al contenido.
  static Route<dynamic> fadeScaleRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, _, _) => page,
      transitionDuration: const Duration(milliseconds: 280),
      transitionsBuilder: (_, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween(begin: 0.96, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  /// Reproductor: sube desde abajo, como se abre en cualquier app de música
  /// al tocar el mini player.
  static Route<dynamic> slideUpRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, _, _) => page,
      transitionDuration: const Duration(milliseconds: 320),
      transitionsBuilder: (_, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return SlideTransition(
          position: Tween(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        );
      },
    );
  }
}
