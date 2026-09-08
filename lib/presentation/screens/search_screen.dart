import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/music_provider.dart';
import '../../providers/view_state.dart';
import '../widgets/artist_card.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/genre_card.dart';
import '../widgets/state_views.dart';
import '../widgets/track_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MusicProvider>().loadGenres();
    });
  }

  // Igual que el _filterAnimes del profe, pero con debounce porque aquí
  // cada tecleo dispara una petición real a la API (no un filtro local).
  void _onChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<MusicProvider>().search(query);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final music = context.watch<MusicProvider>();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: TextField(
              controller: _controller,
              onChanged: _onChanged,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: '¿Qué quieres escuchar?',
                prefixIcon: Icon(
                  LucideIcons.search,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          Expanded(child: _buildResults(music)),
        ],
      ),
    );
  }

  Widget _buildResults(MusicProvider music) {
    switch (music.searchState) {
      case ViewState.initial:
        return _buildExplore(music);
      case ViewState.loading:
        return const LoadingView();
      case ViewState.error:
        return ErrorView(
          message: music.searchError,
          onRetry: () => music.search(music.lastQuery),
        );
      case ViewState.empty:
        return const EmptyView(message: 'No se encontraron resultados');
      case ViewState.success:
        return FadeSlideIn(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              if (music.artistResults.isNotEmpty) ...[
                const Text(
                  'ARTISTAS',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 130,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: music.artistResults.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 16),
                    itemBuilder: (_, i) =>
                        ArtistCard(artist: music.artistResults[i]),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              if (music.trackResults.isNotEmpty) ...[
                const Text(
                  'CANCIONES',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                ...music.trackResults.map(
                  (t) => TrackTile(track: t, queue: music.trackResults),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        );
    }
  }

  /// Lo que se ve antes de escribir nada: grid de géneros, tipo "Explorar"
  /// de Spotify (búsqueda con propósito, no una pantalla vacía).
  Widget _buildExplore(MusicProvider music) {
    switch (music.genresState) {
      case ViewState.loading:
      case ViewState.initial:
        return const LoadingView();
      case ViewState.error:
        return ErrorView(
          message: 'No se pudieron cargar los géneros',
          onRetry: () => music.loadGenres(),
        );
      case ViewState.empty:
        return const EmptyView(message: 'Sin géneros disponibles');
      case ViewState.success:
        return FadeSlideIn(
          child: GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.8,
            ),
            itemCount: music.genres.length,
            itemBuilder: (_, i) => GenreCard(genre: music.genres[i], index: i),
          ),
        );
    }
  }
}
