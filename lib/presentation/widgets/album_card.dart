import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/album.dart';
import 'pressable_scale.dart';

class AlbumCard extends StatelessWidget {
  final Album album;

  const AlbumCard({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.albumDetail,
        arguments: album.id,
      ),
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: album.coverMedium,
                width: 140,
                height: 140,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  color: AppColors.surface,
                  width: 140,
                  height: 140,
                ),
                errorWidget: (_, _, _) => Container(
                  color: AppColors.surface,
                  width: 140,
                  height: 140,
                  child: const Icon(
                    LucideIcons.disc3,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              album.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            if (album.artistName.isNotEmpty)
              Text(
                album.artistName,
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
