import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/routes/app_routes.dart';
import '../../data/models/genre.dart';
import '../widgets/mini_player.dart';
import 'album_screen.dart';
import 'artist_screen.dart';
import 'favorites_screen.dart';
import 'genre_screen.dart';
import 'home_screen.dart';
import 'player_screen.dart';
import 'search_screen.dart';

/// Shell persistente de la app: la barra inferior y el mini player viven
/// aquí y nunca se desmontan. Todo lo demás (Home/Buscar/Favoritos, y las
/// rutas de artista/álbum/reproductor) se navega dentro de un Navigator
/// anidado, así que siempre queda visible dónde estás — igual que Spotify.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final ValueNotifier<int> _tabIndex = ValueNotifier<int>(0);

  void _switchTab(int index) {
    _navigatorKey.currentState?.popUntil((route) => route.isFirst);
    _tabIndex.value = index;
  }

  @override
  void dispose() {
    _tabIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        key: _navigatorKey,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case AppRoutes.artistDetail:
              final artistId = settings.arguments as int;
              return AppRoutes.fadeScaleRoute(ArtistScreen(artistId: artistId));
            case AppRoutes.albumDetail:
              final albumId = settings.arguments as int;
              return AppRoutes.fadeScaleRoute(AlbumScreen(albumId: albumId));
            case AppRoutes.genreDetail:
              final genre = settings.arguments as Genre;
              return AppRoutes.fadeScaleRoute(GenreScreen(genre: genre));
            case AppRoutes.player:
              return AppRoutes.slideUpRoute(const PlayerScreen());
            default:
              return MaterialPageRoute(
                builder: (_) => _ShellTabs(
                  tabIndex: _tabIndex,
                  onGoToSearch: () => _switchTab(1),
                ),
              );
          }
        },
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MiniPlayer(navigatorKey: _navigatorKey),
          ValueListenableBuilder<int>(
            valueListenable: _tabIndex,
            builder: (context, index, _) {
              return BottomNavigationBar(
                currentIndex: index,
                onTap: _switchTab,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(
                      index == 0 ? LucideIcons.house600 : LucideIcons.house,
                    ),
                    label: 'Inicio',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      index == 1 ? LucideIcons.search600 : LucideIcons.search,
                    ),
                    label: 'Buscar',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      index == 2 ? LucideIcons.heart600 : LucideIcons.heart,
                    ),
                    label: 'Favoritos',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ShellTabs extends StatelessWidget {
  final ValueNotifier<int> tabIndex;
  final VoidCallback onGoToSearch;

  const _ShellTabs({required this.tabIndex, required this.onGoToSearch});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: tabIndex,
      builder: (context, index, _) {
        return IndexedStack(
          index: index,
          children: [
            HomeScreen(onGoToSearch: onGoToSearch),
            const SearchScreen(),
            const FavoritesScreen(),
          ],
        );
      },
    );
  }
}
