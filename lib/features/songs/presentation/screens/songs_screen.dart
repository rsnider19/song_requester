import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart' show CircularProgressIndicator, ReorderableListView;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:song_requester/app/router/app_router.dart';
import 'package:song_requester/features/songs/domain/models/performer_song.dart';
import 'package:song_requester/features/songs/presentation/providers/song_library_state_notifier.dart';
import 'package:song_requester/widgets/app_scaffold.dart';

class SongsScreen extends ConsumerStatefulWidget {
  const SongsScreen({super.key});

  @override
  ConsumerState<SongsScreen> createState() => _SongsScreenState();
}

class _SongsScreenState extends ConsumerState<SongsScreen> {
  bool _isEditMode = false;
  String _filterQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final libraryAsync = ref.watch(songLibraryStateProvider);

    return AppScaffold(
      title: Row(
        children: [
          const Expanded(child: Text('Songs')),
          if ((libraryAsync.value?.isNotEmpty ?? false) && _filterQuery.isEmpty)
            ShadButton.ghost(
              size: ShadButtonSize.sm,
              onPressed: () => setState(() => _isEditMode = !_isEditMode),
              child: Text(_isEditMode ? 'Done' : 'Edit'),
            ),
        ],
      ),
      floatingActionButton: _isEditMode
          ? null
          : ShadButton(
              onPressed: _navigateToAddSong,
              size: ShadButtonSize.lg,
              leading: const Icon(LucideIcons.plus, size: 20),
              child: const Text('Add Song'),
            ),
      body: SafeArea(
        child: libraryAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ErrorView(
            message: error.toString(),
            onRetry: () => ref.read(songLibraryStateProvider.notifier).refresh(),
          ),
          data: (library) {
            if (library.isEmpty) return const _EmptyView();

            final filtered = _filterQuery.isEmpty
                ? library
                : library.where((ps) {
                    final q = _filterQuery.toLowerCase();
                    return ps.song.title.toLowerCase().contains(q) || ps.song.artist.toLowerCase().contains(q);
                  }).toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ShadInput(
                    placeholder: const Text('Filter songs...'),
                    leading: const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(LucideIcons.search, size: 16),
                    ),
                    onChanged: (value) => setState(() {
                      _filterQuery = value;
                      if (value.isNotEmpty) _isEditMode = false;
                    }),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    _filterQuery.isNotEmpty
                        ? '${filtered.length} of ${library.length} song${library.length == 1 ? '' : 's'}'
                        : '${library.length} song${library.length == 1 ? '' : 's'}',
                    style: theme.textTheme.muted,
                  ),
                ),
                const Gap(4),
                Expanded(
                  child: _isEditMode
                      ? _EditableList(
                          songs: filtered,
                          onReorder: (oldIndex, newIndex) {
                            var adjustedNew = newIndex;
                            if (adjustedNew > oldIndex) adjustedNew--;
                            unawaited(ref.read(songLibraryStateProvider.notifier).reorder(oldIndex, adjustedNew));
                          },
                          onDelete: _confirmDelete,
                        )
                      : _SongList(songs: filtered),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _navigateToAddSong() {
    const AddSongRoute().go(context);
  }

  void _confirmDelete(PerformerSong performerSong) {
    unawaited(
      showShadDialog<void>(
        context: context,
        builder: (context) => ShadDialog.alert(
          title: const Text('Remove Song'),
          description: Text('Remove "${performerSong.song.title}" from your library?'),
          actions: [
            ShadButton.outline(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ShadButton.destructive(
              child: const Text('Remove'),
              onPressed: () {
                Navigator.of(context).pop();
                unawaited(ref.read(songLibraryStateProvider.notifier).removeSong(performerSong.songId));
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Song list (normal mode)
// ---------------------------------------------------------------------------

class _SongList extends StatelessWidget {
  const _SongList({required this.songs});

  final List<PerformerSong> songs;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) => _SongTile(performerSong: songs[index]),
    );
  }
}

// ---------------------------------------------------------------------------
// Editable list (edit mode — reorder + delete)
// ---------------------------------------------------------------------------

class _EditableList extends StatelessWidget {
  const _EditableList({
    required this.songs,
    required this.onReorder,
    required this.onDelete,
  });

  final List<PerformerSong> songs;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(PerformerSong song) onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return ReorderableListView.builder(
      itemCount: songs.length,
      onReorder: onReorder,
      itemBuilder: (context, index) {
        final ps = songs[index];
        return _ListTile(
          key: ValueKey(ps.performerSongId),
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => onDelete(ps),
                child: Icon(LucideIcons.minus, size: 20, color: theme.colorScheme.destructive),
              ),
              const Gap(8),
              _AlbumArt(url: ps.song.albumArtUrl),
            ],
          ),
          title: Text(ps.song.title, style: theme.textTheme.p),
          subtitle: Text(ps.song.artist, style: theme.textTheme.muted),
          trailing: Icon(LucideIcons.gripVertical, size: 20, color: theme.colorScheme.mutedForeground),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Song tile
// ---------------------------------------------------------------------------

class _SongTile extends StatelessWidget {
  const _SongTile({required this.performerSong});

  final PerformerSong performerSong;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final song = performerSong.song;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          _AlbumArt(url: song.albumArtUrl),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  style: theme.textTheme.p,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  song.artist,
                  style: theme.textTheme.muted,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared widgets
// ---------------------------------------------------------------------------

/// Custom list-tile-like row without importing Material's ListTile.
class _ListTile extends StatelessWidget {
  const _ListTile({
    required this.title,
    super.key,
    this.leading,
    this.subtitle,
    this.trailing,
  });

  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const Gap(12)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                title,
                ?subtitle,
              ],
            ),
          ),
          if (trailing != null) ...[const Gap(12), trailing!],
        ],
      ),
    );
  }
}

class _AlbumArt extends StatelessWidget {
  const _AlbumArt({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
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
                errorWidget: (_, _, _) => _AlbumArtPlaceholder(theme: theme),
              )
            : _AlbumArtPlaceholder(theme: theme),
      ),
    );
  }
}

class _AlbumArtPlaceholder extends StatelessWidget {
  const _AlbumArtPlaceholder({required this.theme});

  final ShadThemeData theme;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: theme.colorScheme.muted,
      child: Center(
        child: Icon(LucideIcons.music, size: 20, color: theme.colorScheme.mutedForeground),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty & error views
// ---------------------------------------------------------------------------

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.music, size: 48, color: theme.colorScheme.mutedForeground),
            const Gap(16),
            Text('No songs yet', style: theme.textTheme.h4),
            const Gap(8),
            Text(
              'Search Spotify to add songs to your library.',
              style: theme.textTheme.muted,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.triangleAlert, size: 48, color: theme.colorScheme.destructive),
            const Gap(16),
            Text('Something went wrong', style: theme.textTheme.h4),
            const Gap(8),
            Text(message, style: theme.textTheme.muted, textAlign: TextAlign.center),
            const Gap(16),
            ShadButton.outline(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
