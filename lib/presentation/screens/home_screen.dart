import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/track.dart';
import '../../providers/music_provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/view_state.dart';
import '../widgets/album_card.dart';
import '../widgets/artist_card.dart';
import '../widgets/gradient_header.dart';
import '../widgets/pressable_scale.dart';
import '../widgets/state_views.dart';
import '../widgets/track_tile.dart';

/// Saludo + ícono según la hora del día, para que el Home se sienta vivo
/// en vez de un "Hola" estático.
({String text, IconData icon}) _greetingForNow() {
  final hour = DateTime.now().hour;
  if (hour < 12) return (text: 'Buenos días', icon: LucideIcons.sunrise);
  if (hour < 19) return (text: 'Buenas tardes', icon: LucideIcons.sun);
  return (text: 'Buenas noches', icon: LucideIcons.moon);
}

class HomeScreen extends StatefulWidget {
  final VoidCallback onGoToSearch;

  const HomeScreen({super.key, required this.onGoToSearch});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MusicProvider>();
      if (provider.homeState == ViewState.initial) {
        provider.loadHome();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final music = context.watch<MusicProvider>();
    final recentlyPlayed = context.watch<PlayerProvider>().recentlyPlayed;
    final greeting = _greetingForNow();

    return GradientHeader(
      height: 260,
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          greeting.icon,
                          color: AppColors.accent,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          greeting.text,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 350.ms).slideX(
                      begin: -0.06,
                      end: 0,
                      curve: Curves.easeOut,
                    ),
                    const Text(
                      '¿Qué quieres escuchar hoy?',
                      style: TextStyle(color: AppColors.textSecondary),
                    ).animate(delay: 80.ms).fadeIn(duration: 350.ms),
                    const SizedBox(height: 16),
                    PressableScale(
                      onTap: widget.onGoToSearch,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              LucideIcons.search,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Buscar música...',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ).animate(delay: 140.ms).fadeIn(duration: 350.ms).slideY(
                      begin: 0.15,
                      end: 0,
                      curve: Curves.easeOut,
                    ),
                  ],
                ),
              ),
            ),
            if (music.homeState == ViewState.loading ||
                music.homeState == ViewState.initial)
              const SliverToBoxAdapter(child: _HomeSkeleton())
            else if (music.homeState == ViewState.error)
              SliverFillRemaining(
                child: ErrorView(
                  message: music.homeError,
                  onRetry: () => music.loadHome(),
                ),
              )
            else
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (recentlyPlayed.isNotEmpty)
                      _Section(
                        key: const ValueKey('section-recent'),
                        title: 'Escuchado recientemente',
                        icon: LucideIcons.history,
                        delayMs: 0,
                        child: SizedBox(
                          height: 190,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            itemCount: recentlyPlayed.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 16),
                            itemBuilder: (_, i) => _RecentTrackCard(
                                  key: ValueKey(
                                    'recent-${recentlyPlayed[i].id}',
                                  ),
                                  track: recentlyPlayed[i],
                                  queue: recentlyPlayed,
                                )
                                .animate(delay: (i * 60).ms)
                                .fadeIn(duration: 300.ms)
                                .slideX(begin: 0.15, end: 0),
                          ),
                        ),
                      ),
                    _Section(
                      key: const ValueKey('section-recommended'),
                      title: 'Recomendado para ti',
                      icon: LucideIcons.sparkle,
                      delayMs: 60,
                      child: Column(
                        children: music.recommendedTracks
                            .take(8)
                            .toList()
                            .asMap()
                            .entries
                            .map(
                              (e) => Padding(
                                key: ValueKey('recommended-${e.value.id}'),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: TrackTile(
                                  track: e.value,
                                  queue: music.recommendedTracks,
                                ),
                              ).animate(delay: (e.key * 50).ms).fadeIn(
                                duration: 300.ms,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    _Section(
                      key: const ValueKey('section-artists'),
                      title: 'Artistas populares',
                      icon: LucideIcons.users,
                      delayMs: 120,
                      child: SizedBox(
                        height: 130,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: music.popularArtists.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: 16),
                          itemBuilder: (_, i) =>
                              ArtistCard(
                                    key: ValueKey(
                                      'artist-${music.popularArtists[i].id}',
                                    ),
                                    artist: music.popularArtists[i],
                                  )
                                  .animate(delay: (i * 60).ms)
                                  .fadeIn(duration: 300.ms)
                                  .slideX(begin: 0.15, end: 0),
                        ),
                      ),
                    ),
                    _Section(
                      key: const ValueKey('section-albums'),
                      title: 'Álbumes destacados',
                      icon: LucideIcons.discAlbum,
                      delayMs: 180,
                      child: SizedBox(
                        height: 190,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: music.popularAlbums.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: 16),
                          itemBuilder: (_, i) =>
                              AlbumCard(
                                    key: ValueKey(
                                      'album-${music.popularAlbums[i].id}',
                                    ),
                                    album: music.popularAlbums[i],
                                  )
                                  .animate(delay: (i * 60).ms)
                                  .fadeIn(duration: 300.ms)
                                  .slideX(begin: 0.15, end: 0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final int delayMs;

  const _Section({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.delayMs = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Row(
            children: [
              Icon(icon, color: AppColors.accent, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        child,
      ],
    ).animate(delay: delayMs.ms).fadeIn(duration: 400.ms).slideY(
      begin: 0.08,
      end: 0,
      curve: Curves.easeOutCubic,
    );
  }
}

class _RecentTrackCard extends StatelessWidget {
  final Track track;
  final List<Track> queue;

  const _RecentTrackCard({super.key, required this.track, required this.queue});

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () {
        context.read<PlayerProvider>().playTrack(track, queue: queue);
        Navigator.pushNamed(context, AppRoutes.player);
      },
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: track.albumCover,
                width: 140,
                height: 140,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) => Container(
                  color: AppColors.surface,
                  width: 140,
                  height: 140,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              track.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            Text(
              track.artistName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton "shimmer" mientras carga el Home, en vez de un spinner suelto:
/// dibuja la silueta del contenido real (filas de canciones + carruseles)
/// para que la carga se sienta parte del diseño, no una pantalla en blanco.
class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  static Widget _bar({double width = double.infinity, double height = 14}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }

  static Widget _box(double size, {double radius = 8}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  static Widget _circle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.surface.withValues(alpha: 0.45),
      period: const Duration(milliseconds: 1400),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _bar(width: 150, height: 17),
            const SizedBox(height: 16),
            for (var i = 0; i < 3; i++) ...[
              Row(
                children: [
                  _box(44, radius: 6),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _bar(height: 13),
                        const SizedBox(height: 8),
                        _bar(width: 90, height: 11),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
            ],
            const SizedBox(height: 8),
            _bar(width: 150, height: 17),
            const SizedBox(height: 16),
            SizedBox(
              height: 110,
              child: Row(
                children: [
                  for (var i = 0; i < 4; i++) ...[
                    _circle(88),
                    const SizedBox(width: 16),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
