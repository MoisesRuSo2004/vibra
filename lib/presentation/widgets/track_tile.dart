import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/track.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/player_provider.dart';
import 'favorite_button.dart';

class TrackTile extends StatelessWidget {
  final Track track;
  final int? index;
  final List<Track>? queue;

  const TrackTile({super.key, required this.track, this.index, this.queue});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final player = context.watch<PlayerProvider>();
    final isCurrentTrack = player.currentTrack?.id == track.id;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: index != null
          ? SizedBox(
              width: 40,
              child: Text(
                '${index! + 1}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CachedNetworkImage(
                imageUrl: track.albumCover,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) =>
                    Container(color: AppColors.surface, width: 44, height: 44),
              ),
            ),
      title: Text(
        track.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isCurrentTrack ? AppColors.accent : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: track.artistName.isNotEmpty
          ? Text(track.artistName, maxLines: 1, overflow: TextOverflow.ellipsis)
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FavoriteButton(
            isFavorite: favorites.isFavorite(track.id),
            onTap: () => favorites.toggleFavorite(track),
          ),
          Text(
            track.durationLabel,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
      onTap: () {
        context.read<PlayerProvider>().playTrack(
          track,
          queue: queue ?? [track],
        );
        Navigator.pushNamed(context, AppRoutes.player);
      },
    );
  }
}
