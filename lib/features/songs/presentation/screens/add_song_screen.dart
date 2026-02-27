import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:song_requester/features/songs/domain/models/spotify_search_result.dart';
import 'package:song_requester/features/songs/presentation/providers/song_library_state_notifier.dart';
import 'package:song_requester/features/songs/presentation/providers/spotify_search_provider.dart';
import 'package:song_requester/widgets/app_scaffold.dart';

class AddSongScreen extends ConsumerStatefulWidget {
  const AddSongScreen({super.key});

  @override
  ConsumerState<AddSongScreen> createState() => _AddSongScreenState();
}

class _AddSongScreenState extends ConsumerState<AddSongScreen> {
  String _query = '';

  /// Track IDs added optimistically during this session (before the library
  /// provider has refreshed).
  final Set<String> _optimisticTrackIds = {};

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    // Derive track IDs reactively so we pick up changes if the library loads
    // after this screen was already open.
    final libraryAsync = ref.watch(songLibraryStateProvider);
    final libraryTrackIds = libraryAsync.value?.map((ps) => ps.song.spotifyTrackId).toSet() ?? <String>{};
    final allTrackIds = {...libraryTrackIds, ..._optimisticTrackIds};
    final libraryLoaded = libraryAsync.hasValue;

    return AppScaffold(
      title: Row(
        children: [
          ShadButton.ghost(
            size: ShadButtonSize.sm,
            leading: const Icon(LucideIcons.arrowLeft, size: 20),
            onPressed: () => context.pop(),
          ),
          const Gap(8),
          const Expanded(child: Text('Add Song')),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ShadInput(
                placeholder: const Text('Search Spotify...'),
                leading: const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(LucideIcons.search, size: 16),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            Expanded(
              child: _query.trim().isEmpty
                  ? _SearchPrompt(theme: theme)
                  : _SearchResults(
                      query: _query,
                      libraryTrackIds: allTrackIds,
                      libraryTrackIdsLoaded: libraryLoaded,
                      onAdd: _addSong,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addSong(SpotifySearchResult result) async {
    // Optimistically mark as in library.
    setState(() => _optimisticTrackIds.add(result.spotifyTrackId));

    try {
      final softLimitReached = await ref.read(songLibraryStateProvider.notifier).addSong(result);

      if (!mounted) return;

      ShadToaster.of(context).show(
        ShadToast(
          title: Text('"${result.title}" added to your library'),
        ),
      );

      if (softLimitReached) {
        ShadToaster.of(context).show(
          const ShadToast(
            title: Text('Your library has 500+ songs'),
            description: Text('Consider removing songs you no longer perform.'),
          ),
        );
      }
    } on Exception {
      if (!mounted) return;
      // Revert optimistic update.
      setState(() => _optimisticTrackIds.remove(result.spotifyTrackId));

      ShadToaster.of(context).show(
        const ShadToast.destructive(
          title: Text('Could not add song'),
          description: Text('Please try again.'),
        ),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Search prompt (empty query)
// ---------------------------------------------------------------------------

class _SearchPrompt extends StatelessWidget {
  const _SearchPrompt({required this.theme});

  final ShadThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.search, size: 48, color: theme.colorScheme.mutedForeground),
          const Gap(16),
          Text('Search for songs', style: theme.textTheme.muted),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Search results
// ---------------------------------------------------------------------------

class _SearchResults extends ConsumerWidget {
  const _SearchResults({
    required this.query,
    required this.libraryTrackIds,
    required this.libraryTrackIdsLoaded,
    required this.onAdd,
  });

  final String query;
  final Set<String> libraryTrackIds;
  final bool libraryTrackIdsLoaded;
  final Future<void> Function(SpotifySearchResult result) onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final searchAsync = ref.watch(spotifySearchProvider(query));

    return searchAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.triangleAlert, size: 48, color: theme.colorScheme.destructive),
              const Gap(16),
              Text('Search failed', style: theme.textTheme.h4),
              const Gap(8),
              Text(error.toString(), style: theme.textTheme.muted, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
      data: (results) {
        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.searchX, size: 48, color: theme.colorScheme.mutedForeground),
                const Gap(16),
                Text('No songs found', style: theme.textTheme.muted),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final result = results[index];
            final inLibrary = libraryTrackIdsLoaded && libraryTrackIds.contains(result.spotifyTrackId);

            return _SearchResultTile(
              result: result,
              inLibrary: inLibrary,
              onAdd: () => onAdd(result),
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Search result tile
// ---------------------------------------------------------------------------

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.result,
    required this.inLibrary,
    required this.onAdd,
  });

  final SpotifySearchResult result;
  final bool inLibrary;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return GestureDetector(
      onTap: inLibrary ? null : onAdd,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            _SearchAlbumArt(url: result.albumArtUrl, theme: theme),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.title,
                    style: theme.textTheme.p,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    result.artist,
                    style: theme.textTheme.muted,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Gap(12),
            if (inLibrary)
              Icon(LucideIcons.check, size: 20, color: theme.colorScheme.primary)
            else
              Icon(LucideIcons.plus, size: 20, color: theme.colorScheme.mutedForeground),
          ],
        ),
      ),
    );
  }
}

class _SearchAlbumArt extends StatelessWidget {
  const _SearchAlbumArt({required this.theme, this.url});

  final String? url;
  final ShadThemeData theme;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: theme.radius,
      child: SizedBox(
        width: 44,
        height: 44,
        child: url != null
            ? CachedNetworkImage(
                imageUrl: url!,
                fit: BoxFit.cover,
                placeholder: (_, _) => ColoredBox(color: theme.colorScheme.muted),
                errorWidget: (_, _, _) => ColoredBox(
                  color: theme.colorScheme.muted,
                  child: Center(child: Icon(LucideIcons.music, size: 20, color: theme.colorScheme.mutedForeground)),
                ),
              )
            : ColoredBox(
                color: theme.colorScheme.muted,
                child: Center(child: Icon(LucideIcons.music, size: 20, color: theme.colorScheme.mutedForeground)),
              ),
      ),
    );
  }
}
