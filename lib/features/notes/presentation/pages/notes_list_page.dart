import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import 'package:nova_assistant/core/theme/app_colors.dart';
import '../controllers/notes_controller.dart';
import '../widgets/note_card.dart';
import '../widgets/note_search_bar.dart';

/// Beautiful notes list page with search, pinned section, and grid/list toggle
class NotesListPage extends ConsumerWidget {
  const NotesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesControllerProvider);
    final pinnedNotes = ref.watch(pinnedNotesProvider);
    final unpinnedNotes = ref.watch(unpinnedNotesProvider);
    final viewMode = ref.watch(notesViewModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notes',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              viewMode == NotesViewMode.grid
                  ? Icons.view_list_rounded
                  : Icons.grid_view_rounded,
              color: isDark ? NovaColors.darkOnSurfaceVariant : NovaColors.lightOnSurfaceVariant,
            ),
            onPressed: () {
              ref.read(notesViewModeProvider.notifier).state =
                  viewMode == NotesViewMode.grid ? NotesViewMode.list : NotesViewMode.grid;
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: NoteSearchBar(
              onChanged: (query) {
                ref.read(notesSearchQueryProvider.notifier).state = query;
              },
            ),
          ),

          // Notes list
          Expanded(
            child: notesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: NovaColors.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load notes',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref.read(notesControllerProvider.notifier).loadNotes(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (allNotes) {
                if (allNotes.isEmpty) {
                  return _buildEmptyState(context);
                }

                return RefreshIndicator(
                  onRefresh: () => ref.read(notesControllerProvider.notifier).loadNotes(),
                  color: Theme.of(context).colorScheme.primary,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // Pinned section
                      if (pinnedNotes.isNotEmpty) ...[
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                          sliver: SliverToBoxAdapter(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.push_pin_rounded,
                                  size: 14,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'PINNED',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.2,
                                      ),
                                ),
                              ],
                            )
                                .animate()
                                .fadeIn(duration: 300.ms)
                                .slideX(begin: -0.05, end: 0, duration: 300.ms),
                          ),
                        ),
                        _buildNotesSection(
                          context,
                          ref,
                          pinnedNotes,
                          viewMode,
                        ),
                      ],

                      // Others section
                      if (unpinnedNotes.isNotEmpty && pinnedNotes.isNotEmpty)
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                          sliver: SliverToBoxAdapter(
                            child: Text(
                              'OTHERS',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: isDark
                                        ? NovaColors.darkOnSurfaceVariant
                                        : NovaColors.lightOnSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
                                  ),
                            )
                                .animate()
                                .fadeIn(duration: 300.ms, delay: 100.ms)
                                .slideX(begin: -0.05, end: 0, duration: 300.ms),
                          ),
                        ),

                      if (unpinnedNotes.isNotEmpty)
                        _buildNotesSection(
                          context,
                          ref,
                          unpinnedNotes,
                          viewMode,
                        ),

                      // Bottom padding
                      const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/notes/editor'),
        child: const Icon(Icons.add_rounded),
      )
          .animate()
          .scale(
            begin: const Offset(0, 0),
            end: const Offset(1, 1),
            duration: 400.ms,
            delay: 200.ms,
            curve: Curves.elasticOut,
          ),
    );
  }

  Widget _buildNotesSection(
    BuildContext context,
    WidgetRef ref,
    List notes,
    NotesViewMode viewMode,
  ) {
    if (viewMode == NotesViewMode.grid) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.85,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final note = notes[index];
              return NoteCard(
                note: note,
                onTap: () => context.push('/notes/editor?id=${note.id}'),
                onPinToggle: () =>
                    ref.read(notesControllerProvider.notifier).togglePin(note.id),
                onDelete: () =>
                    ref.read(notesControllerProvider.notifier).deleteNote(note.id),
              )
                  .animate()
                  .fadeIn(
                    duration: 350.ms,
                    delay: Duration(milliseconds: 50 * index),
                  )
                  .scale(
                    begin: const Offset(0.95, 0.95),
                    end: const Offset(1, 1),
                    duration: 350.ms,
                    delay: Duration(milliseconds: 50 * index),
                    curve: Curves.easeOut,
                  );
            },
            childCount: notes.length,
          ),
        ),
      );
    }

    // List view
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final note = notes[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: NoteCard(
                note: note,
                onTap: () => context.push('/notes/editor?id=${note.id}'),
                onPinToggle: () =>
                    ref.read(notesControllerProvider.notifier).togglePin(note.id),
                onDelete: () =>
                    ref.read(notesControllerProvider.notifier).deleteNote(note.id),
              )
                  .animate()
                  .fadeIn(
                    duration: 350.ms,
                    delay: Duration(milliseconds: 50 * index),
                  )
                  .slideX(
                    begin: 0.05,
                    end: 0,
                    duration: 350.ms,
                    delay: Duration(milliseconds: 50 * index),
                    curve: Curves.easeOut,
                  ),
            );
          },
          childCount: notes.length,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.note_alt_outlined,
            size: 72,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No notes yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to create your first note',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? NovaColors.darkOnSurfaceVariant
                      : NovaColors.lightOnSurfaceVariant,
                ),
          ),
        ],
      )
          .animate()
          .fadeIn(duration: 500.ms)
          .scale(
            begin: const Offset(0.9, 0.9),
            end: const Offset(1, 1),
            duration: 500.ms,
            curve: Curves.easeOut,
          ),
    );
  }
}
