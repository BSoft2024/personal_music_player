import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../widgets/cover_art.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlayerProvider>();
    final song = provider.currentSong;
    final theme = Theme.of(context);

    if (song == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('No track selected')),
      );
    }

    final isFav = provider.isFavorite(song);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  Text(
                    'NOW PLAYING',
                    style: theme.textTheme.labelMedium?.copyWith(
                      letterSpacing: 1.2,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFav ? Colors.redAccent : null,
                    ),
                    onPressed: () => provider.toggleFavorite(song),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: AspectRatio(
                aspectRatio: 1,
                child: CoverArt(
                  assetPath: song.coverAsset,
                  size: double.infinity,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const Spacer(flex: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  Text(
                    song.title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${song.album}  ·  ${song.year}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  if (song.instruments.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 6,
                      runSpacing: 4,
                      children: song.instruments
                          .map((i) => Chip(
                                label: Text(i, style: const TextStyle(fontSize: 11)),
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: StreamBuilder<Duration>(
                stream: provider.player.positionStream,
                builder: (context, snap) {
                  final pos = snap.data ?? Duration.zero;
                  final total = provider.player.duration ?? Duration.zero;
                  return Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                        ),
                        child: Slider(
                          value: total.inMilliseconds == 0
                              ? 0
                              : pos.inMilliseconds.clamp(0, total.inMilliseconds).toDouble(),
                          max: total.inMilliseconds == 0 ? 1 : total.inMilliseconds.toDouble(),
                          onChanged: (v) => provider.seek(Duration(milliseconds: v.round())),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_fmt(pos), style: theme.textTheme.bodySmall),
                            Text(_fmt(total), style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 32,
                  icon: Icon(
                    Icons.shuffle_rounded,
                    color: provider.shuffle ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: provider.toggleShuffle,
                ),
                const SizedBox(width: 8),
                IconButton(
                  iconSize: 42,
                  icon: const Icon(Icons.skip_previous_rounded),
                  onPressed: provider.previous,
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colorScheme.primary),
                  child: IconButton(
                    iconSize: 48,
                    color: theme.colorScheme.onPrimary,
                    icon: Icon(provider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                    onPressed: provider.togglePlayPause,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  iconSize: 42,
                  icon: const Icon(Icons.skip_next_rounded),
                  onPressed: provider.next,
                ),
                const SizedBox(width: 8),
                const SizedBox(width: 48),
              ],
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
