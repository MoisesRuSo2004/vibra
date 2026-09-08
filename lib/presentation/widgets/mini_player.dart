import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/player_provider.dart';

class MiniPlayer extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const MiniPlayer({super.key, required this.navigatorKey});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  // Sin esto, tocar varias veces seguidas (antes de que termine la
  // transición) empuja una ruta del reproductor por cada toque.
  bool _opening = false;

  Future<void> _openPlayer() async {
    if (_opening) return;
    _opening = true;
    await widget.navigatorKey.currentState?.pushNamed(AppRoutes.player);
    _opening = false;
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final track = player.currentTrack;

    final progress = player.duration.inMilliseconds == 0
        ? 0.0
        : player.position.inMilliseconds / player.duration.inMilliseconds;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      height: track == null ? 0 : 64,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(color: AppColors.surface),
      child: track == null
          ? null
          : GestureDetector(
              onTap: _openPlayer,
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 2,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: CachedNetworkImage(
                              imageUrl: track.albumCover,
                              width: 40,
                              height: 40,
                              memCacheWidth: 80,
                              memCacheHeight: 80,
                              fit: BoxFit.cover,
                              errorWidget: (_, _, _) => Container(
                                color: AppColors.background,
                                width: 40,
                                height: 40,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
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
                          IconButton(
                            icon: const Icon(LucideIcons.skipBack),
                            iconSize: 20,
                            color: AppColors.textPrimary,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            onPressed: () => player.playPrevious(),
                          ),
                          IconButton(
                            icon: Icon(
                              player.isPlaying
                                  ? LucideIcons.circlePause
                                  : LucideIcons.circlePlay,
                              color: AppColors.textPrimary,
                              size: 32,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                            onPressed: () => player.togglePlayPause(),
                          ),
                          IconButton(
                            icon: const Icon(LucideIcons.skipForward),
                            iconSize: 20,
                            color: AppColors.textPrimary,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            onPressed: () => player.playNext(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
