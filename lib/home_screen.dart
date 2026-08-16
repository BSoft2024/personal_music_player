import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../widgets/song_tile.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/mini_player.dart';
import 'player_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlayerProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Music',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        '${provider.songs.length} tracks',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Favorites only',
                    icon: Icon(
                      provider.showFavoritesOnly ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: provider.showFavoritesOnly ? Colors.redAccent : theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: provider.toggleFavoritesOnly,
                  ),
                  IconButton(
                    tooltip: 'Shuffle',
                    icon: Icon(
                      Icons.shuffle_rounded,
                      color: provider.shuffle ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: provider.toggleShuffle,
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.sort_rounded),
                    tooltip: 'Sort',
                    onSelected: (value) {
                      switch (value) {
                        case 'title': provider.setSort(SortBy.title); break;
                        case 'album': provider.setSort(SortBy.album); break;
                        case 'year': provider.setSort(SortBy.year); break;
                        case 'type': provider.setSort(SortBy.type); break;
                        case 'length': provider.setSort(SortBy.length); break;
                      }
                    },
                    itemBuilder: (context) => [
                      _sortItem(context, provider, 'Title', 'title', SortBy.title),
                      _sortItem(context, provider, 'Album', 'album', SortBy.album),
                      _sortItem(context, provider, 'Year', 'year', SortBy.year),
                      _sortItem(context, provider, 'Type', 'type', SortBy.type),
                      _sortItem(context, provider, 'Length', 'length', SortBy.length),
                    ],
                  ),
                  IconButton(
                    tooltip: 'Filter',
                    icon: Badge(
                      isLabelVisible: _hasActiveFilters(provider),
                      child: const Icon(Icons.filter_list_rounded),
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const FilterSheet(),
                      );
                    },
                  ),
                ],
              ),
            ),
            if (_hasActiveFilters(provider) || provider.showFavoritesOnly)
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    if (provider.showFavoritesOnly)
                      _chip(context, 'Favorites', provider.toggleFavoritesOnly),
                    ...provider.selectedInstruments.map((i) => _chip(context, i, () => provider.toggleInstrument(i))),
                    ...provider.selectedTypes.map((t) => _chip(context, t, () => provider.toggleType(t))),
                    ...provider.selectedYears.map((y) => _chip(context, y.toString(), () => provider.toggleYear(y))),
                    if (provider.selectedAlbums.isNotEmpty)
                      _chip(context, '${provider.selectedAlbums.length} album(s)', provider.clearAllFilters),
                  ],
                ),
              ),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.error != null
                      ? Center(child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text('Error: ${provider.error}', textAlign: TextAlign.center),
                        ))
                      : provider.songs.isEmpty
                          ? const Center(child: Text('No tracks match the current filters'))
                          : ListView.builder(
                              itemCount: provider.songs.length,
                              itemBuilder: (context, index) {
                                final song = provider.songs[index];
                                return SongTile(
                                  song: song,
                                  onTap: () => provider.playSong(song),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MiniPlayer(
        onTap: () {
          if (provider.currentSong != null) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PlayerScreen()),
            );
          }
        },
      ),
    );
  }

  bool _hasActiveFilters(PlayerProvider p) =>
      p.selectedInstruments.isNotEmpty ||
      p.selectedAlbums.isNotEmpty ||
      p.selectedTypes.isNotEmpty ||
      p.selectedYears.isNotEmpty;

  PopupMenuItem<String> _sortItem(BuildContext context, PlayerProvider provider, String label, String value, SortBy by) {
    final isActive = provider.sortBy == by;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          if (isActive)
            Icon(
              provider.sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String label, VoidCallback onDeleted) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Chip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        deleteIcon: const Icon(Icons.close, size: 14),
        onDeleted: onDeleted,
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
