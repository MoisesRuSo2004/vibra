import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/genre.dart';
import '../../providers/music_provider.dart';
import '../../providers/view_state.dart';
import '../widgets/album_card.dart';
import '../widgets/artist_card.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/gradient_header.dart';
import '../widgets/state_views.dart';
import '../widgets/track_tile.dart';

class GenreScreen extends StatefulWidget {
  final Genre genre;

  const GenreScreen({super.key, required this.genre});

  @override
  State<GenreScreen> createState() => _GenreScreenState();
}

class _GenreScreenState extends State<GenreScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MusicProvider>().loadGenreDetail(widget.genre);
    });
  }

  @override
  Widget build(BuildContext context) {
    final music = context.watch<MusicProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(widget.genre.name)),
      body: GradientHeader(
        height: 220,
        child: Builder(
          builder: (_) {
            if (music.genreDetailState == ViewState.loading ||
                music.genreDetailState == ViewState.initial) {
              return const LoadingView();
            }
            if (music.genreDetailState == ViewState.error) {
              return ErrorView(
                message: music.genreDetailError,
                onRetry: () => music.loadGenreDetail(widget.genre),
              );
            }

            return FadeSlideIn(
              child: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  if (music.genreArtists.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                        child: Text(
                          'Artistas',
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
                        height: 130,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: music.genreArtists.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 16),
                          itemBuilder: (_, i) =>
                              ArtistCard(artist: music.genreArtists[i]),
                        ),
                      ),
                    ),
                  ],
                  if (music.genreAlbums.isNotEmpty) ...[
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
                          itemCount: music.genreAlbums.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 16),
                          itemBuilder: (_, i) =>
                              AlbumCard(album: music.genreAlbums[i]),
                        ),
                      ),
                    ),
                  ],
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                      child: Text(
                        'Canciones',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  SliverList.list(
                    children: music.genreTracks
                        .map(
                          (t) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TrackTile(
                              track: t,
                              queue: music.genreTracks,
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
