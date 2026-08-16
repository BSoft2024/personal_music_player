import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';

class FilterSheet extends StatelessWidget {
  const FilterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlayerProvider>();
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                child: Row(
                  children: [
                    Text('Filters', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    TextButton(onPressed: provider.clearAllFilters, child: const Text('Clear all')),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  children: [
                    if (provider.availableInstruments.isNotEmpty) ...[
                      _SectionTitle(title: 'Instrumentation', subtitle: 'Show tracks that contain all selected instruments'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: provider.availableInstruments.map((instr) {
                          final selected = provider.selectedInstruments.contains(instr);
                          return FilterChip(
                            label: Text(instr, style: const TextStyle(fontSize: 13)),
                            selected: selected,
                            onSelected: (_) => provider.toggleInstrument(instr),
                            selectedColor: theme.colorScheme.primaryContainer,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 28),
                    ],
                    if (provider.availableTypes.isNotEmpty) ...[
                      const _SectionTitle(title: 'Type'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: provider.availableTypes.map((t) {
                          final selected = provider.selectedTypes.contains(t);
                          return FilterChip(
                            label: Text(t),
                            selected: selected,
                            onSelected: (_) => provider.toggleType(t),
                            selectedColor: theme.colorScheme.primaryContainer,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 28),
                    ],
                    if (provider.availableYears.isNotEmpty) ...[
                      const _SectionTitle(title: 'Release Year'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: provider.availableYears.map((y) {
                          final selected = provider.selectedYears.contains(y);
                          return FilterChip(
                            label: Text(y.toString()),
                            selected: selected,
                            onSelected: (_) => provider.toggleYear(y),
                            selectedColor: theme.colorScheme.primaryContainer,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 28),
                    ],
                    if (provider.availableAlbums.isNotEmpty) ...[
                      _SectionTitle(title: 'Album / Release', subtitle: '${provider.availableAlbums.length} releases'),
                      const SizedBox(height: 8),
                      ...provider.availableAlbums.map((album) {
                        final selected = provider.selectedAlbums.contains(album);
                        return CheckboxListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(album, style: const TextStyle(fontSize: 14)),
                          value: selected,
                          onChanged: (_) => provider.toggleAlbum(album),
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  const _SectionTitle({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(subtitle!, style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            )),
          ),
      ],
    );
  }
}
