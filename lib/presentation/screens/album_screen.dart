import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/music_provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/view_state.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/gradient_header.dart';
import '../widgets/state_views.dart';
import '../widgets/track_tile.dart';

class AlbumScreen extends StatefulWidget {
  final int albumId;

  const AlbumScreen({super.key, required this.albumId});

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MusicProvider>().loadAlbumDetail(widget.albumId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final music = context.watch<MusicProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: GradientHeader(
        height: 340,
        child: Builder(
          builder: (_) {
            if (music.albumDetailState == ViewState.loading ||
                music.albumDetailState == ViewState.initial) {
              return const LoadingView();
            }
            if (music.albumDetailState == ViewState.error) {
              return ErrorView(
                message: music.albumDetailError,
                onRetry: () => music.loadAlbumDetail(widget.albumId),
              );
            }

            final album = music.selectedAlbum!;
            final tracks = music.albumTracks;

            return FadeSlideIn(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: album.coverBig,
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            album.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            album.artistName,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 12,
                              ),
                            ),
                            onPressed: tracks.isEmpty
                                ? null
                                : () {
                                    context.read<PlayerProvider>().playTrack(
                                      tracks.first,
                                      queue: tracks,
                                    );
                                    Navigator.pushNamed(context, '/player');
                                  },
                            icon: const Icon(LucideIcons.play),
                            label: const Text('Reproducir'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverList.list(
                    children: tracks
                        .asMap()
                        .entries
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TrackTile(
                              track: e.value,
                              index: e.key,
                              queue: tracks,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
