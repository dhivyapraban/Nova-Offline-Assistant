import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import 'package:nova_assistant/core/theme/app_colors.dart';
import '../../domain/entities/note.dart';
import '../controllers/notes_controller.dart';

/// Note editor page for creating and editing notes
class NoteEditorPage extends ConsumerStatefulWidget {
  final String? noteId;

  const NoteEditorPage({super.key, this.noteId});

  @override
  ConsumerState<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends ConsumerState<NoteEditorPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  bool _isPinned = false;
  int? _selectedColor;
  Note? _existingNote;
  bool _isLoading = true;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _titleController.addListener(_markChanged);
    _contentController.addListener(_markChanged);
    _loadNote();
  }

  void _markChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  Future<void> _loadNote() async {
    if (widget.noteId != null) {
      final note = await ref
          .read(notesControllerProvider.notifier)
          .getNoteById(widget.noteId!);
      if (note != null && mounted) {
        setState(() {
          _existingNote = note;
          _titleController.text = note.title;
          _contentController.text = note.content;
          _isPinned = note.isPinned;
          _selectedColor = note.color;
          _isLoading = false;
          _hasChanges = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) return;

    final controller = ref.read(notesControllerProvider.notifier);

    if (_existingNote != null) {
      await controller.updateNote(
        _existingNote!.copyWith(
          title: title,
          content: content,
          isPinned: _isPinned,
          color: _selectedColor,
        ),
      );
    } else {
      await controller.createNote(
        title: title.isEmpty ? 'Untitled' : title,
        content: content,
        color: _selectedColor,
        isPinned: _isPinned,
      );
    }
    _hasChanges = false;
  }

  Future<void> _deleteNote() async {
    if (_existingNote == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('This note will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(color: NovaColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref
          .read(notesControllerProvider.notifier)
          .deleteNote(_existingNote!.id);
      if (mounted) context.pop();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop && _hasChanges) {
          await _saveNote();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _existingNote != null ? 'Edit Note' : 'New Note',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          actions: [
            // Pin toggle
            IconButton(
              icon: Icon(
                _isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                color: _isPinned
                    ? Theme.of(context).colorScheme.primary
                    : (isDark ? NovaColors.darkOnSurfaceVariant : NovaColors.lightOnSurfaceVariant),
              ),
              onPressed: () {
                setState(() {
                  _isPinned = !_isPinned;
                  _hasChanges = true;
                });
              },
            ),

            // Delete (only for existing notes)
            if (_existingNote != null)
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: NovaColors.error,
                ),
                onPressed: _deleteNote,
              ),

            // Save
            IconButton(
              icon: Icon(
                Icons.check_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () async {
                await _saveNote();
                if (mounted) context.pop();
              },
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    // Title field
                    TextField(
                      controller: _titleController,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      decoration: InputDecoration(
                        hintText: 'Title',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? NovaColors.darkOnSurfaceVariant.withValues(alpha: 0.4)
                                  : NovaColors.lightOnSurfaceVariant.withValues(alpha: 0.4),
                            ),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: null,
                    )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: -0.05, end: 0, duration: 400.ms),

                    // Content field
                    TextField(
                      controller: _contentController,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            height: 1.6,
                          ),
                      decoration: InputDecoration(
                        hintText: 'Start writing...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: isDark
                                  ? NovaColors.darkOnSurfaceVariant.withValues(alpha: 0.4)
                                  : NovaColors.lightOnSurfaceVariant.withValues(alpha: 0.4),
                            ),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 100.ms)
                        .slideY(begin: 0.03, end: 0, duration: 400.ms),
                  ],
                ),
              ),
            ),

            // Color picker bottom bar
            _buildColorPickerBar(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPickerBar(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? NovaColors.darkSurface : NovaColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? NovaColors.darkOutline : NovaColors.lightOutline,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Text(
              'Color',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isDark
                        ? NovaColors.darkOnSurfaceVariant
                        : NovaColors.lightOnSurfaceVariant,
                  ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: NovaColors.noteColors.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final color = NovaColors.noteColors[index];
                    final isSelected = _selectedColor == color.toARGB32();
                    final isDefault = index == 0 && _selectedColor == null;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = index == 0 ? null : color.toARGB32();
                          _hasChanges = true;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: (isSelected || isDefault)
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: (isSelected || isDefault)
                            ? Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 200.ms)
        .slideY(begin: 0.2, end: 0, duration: 400.ms);
  }
}
