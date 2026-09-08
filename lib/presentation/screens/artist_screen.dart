import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/music_provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/view_state.dart';
import '../widgets/album_card.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/gradient_header.dart';
import '../widgets/state_views.dart';
import '../widgets/track_tile.dart';

class ArtistScreen extends StatefulWidget {
  final int artistId;

  const ArtistScreen({super.key, required this.artistId});

  @override
  State<ArtistScreen> createState() => _ArtistScreenState();
}

class _ArtistScreenState extends State<ArtistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MusicProvider>().loadArtistDetail(widget.artistId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final music = context.watch<MusicProvider>();

    return Scaffold(
      body: GradientHeader(
        height: 340,
        child: SafeArea(
          child: Builder(
            builder: (_) {
              if (music.artistDetailState == ViewState.loading ||
                  music.artistDetailState == ViewState.initial) {
                return const LoadingView();
              }
              if (music.artistDetailState == ViewState.error) {
                return ErrorView(
                  message: music.artistDetailError,
                  onRetry: () => music.loadArtistDetail(widget.artistId),
                );
              }

              final artist = music.selectedArtist!;
              return FadeSlideIn(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(LucideIcons.arrowLeft),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                            ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: artist.pictureBig,
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              artist.name,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${artist.nbFan} fans',
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
                              onPressed: music.artistTopTracks.isEmpty
                                  ? null
                                  : () {
                                      context.read<PlayerProvider>().playTrack(
                                        music.artistTopTracks.first,
                                        queue: music.artistTopTracks,
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
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                        child: Text(
                          'Canciones populares',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SliverList.list(
                      children: music.artistTopTracks
                          .map(
                            (t) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: TrackTile(
                                track: t,
                                queue: music.artistTopTracks,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    if (music.artistAlbums.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                          child: Text(
                            'Álbumes',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 190,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: music.artistAlbums.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 16),
                            itemBuilder: (_, i) =>
                                AlbumCard(album: music.artistAlbums[i]),
                          ),
                        ),
                      ),
                    ],
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
