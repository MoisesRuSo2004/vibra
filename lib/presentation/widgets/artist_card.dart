import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/artist.dart';
import 'pressable_scale.dart';

class ArtistCard extends StatelessWidget {
  final Artist artist;

  const ArtistCard({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.artistDetail,
        arguments: artist.id,
      ),
      child: SizedBox(
        width: 100,
        child: Column(
          children: [
            Hero(
              tag: 'artist-picture-${artist.id}',
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: artist.pictureMedium,
                  width: 88,
                  height: 88,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(
                    color: AppColors.surface,
                    width: 88,
                    height: 88,
                  ),
                  errorWidget: (_, _, _) => Container(
                    color: AppColors.surface,
                    width: 88,
                    height: 88,
                    child: const Icon(
                      LucideIcons.circleUser,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              artist.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
