import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/player_provider.dart';
import '../widgets/favorite_button.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final favorites = context.watch<FavoritesProvider>();
    final track = player.currentTrack;

    if (track == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Nada reproduciéndose',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final durationMs = player.duration.inMilliseconds == 0
        ? 1
        : player.duration.inMilliseconds;

    return Scaffold(
      appBar: AppBar(title: const Text('Reproduciendo')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final size = [
                        constraints.maxWidth,
                        constraints.maxHeight,
                        280.0,
                      ].reduce((a, b) => a < b ? a : b);
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: track.albumCover,
                          width: size,
                          height: size,
                          memCacheWidth: (size * 2).round(),
                          memCacheHeight: (size * 2).round(),
                          fit: BoxFit.contain,
                          errorWidget: (_, _, _) => Container(
                            width: size,
                            height: size,
                            color: AppColors.surface,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          track.artistName,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FavoriteButton(
                    isFavorite: favorites.isFavorite(track.id),
                    onTap: () => favorites.toggleFavorite(track),
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(trackHeight: 3),
                child: Slider(
                  value: player.position.inMilliseconds
                      .clamp(0, durationMs)
                      .toDouble(),
                  max: durationMs.toDouble(),
                  activeColor: AppColors.accent,
                  inactiveColor: Colors.white24,
                  onChanged: (v) =>
                      player.seek(Duration(milliseconds: v.round())),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(player.position),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _formatDuration(player.duration),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    iconSize: 28,
                    icon: const Icon(
                      LucideIcons.skipBack,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () => player.playPrevious(),
                  ),
                  GestureDetector(
                    onTap: () => player.togglePlayPause(),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        player.isPlaying ? LucideIcons.pause : LucideIcons.play,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  ),
                  IconButton(
                    iconSize: 28,
                    icon: const Icon(
                      LucideIcons.skipForward,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () => player.playNext(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(
                      LucideIcons.shuffle,
                      color: player.isShuffleOn
                          ? AppColors.accent
                          : AppColors.textSecondary,
                    ),
                    onPressed: () => player.toggleShuffle(),
                  ),
                  IconButton(
                    icon: Icon(
                      player.repeatMode == TrackRepeatMode.one
                          ? LucideIcons.repeat1
                          : LucideIcons.repeat,
                      color: player.repeatMode == TrackRepeatMode.off
                          ? AppColors.textSecondary
                          : AppColors.accent,
                    ),
                    onPressed: () => player.cycleRepeatMode(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Preview de 30s — cortesía de la API de Deezer',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
