import 'package:flutter/material.dart';

import 'package:nova_assistant/core/theme/app_colors.dart';
import '../../domain/entities/note.dart';

/// Individual note card with color, pin indicator, and content preview
class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onPinToggle;
  final VoidCallback? onDelete;

  const NoteCard({
    super.key,
    required this.note,
    this.onTap,
    this.onLongPress,
    this.onPinToggle,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = note.color != null
        ? Color(note.color!)
        : (isDark ? NovaColors.darkSurface : NovaColors.lightSurface);
    final borderColor = isDark ? NovaColors.darkOutline : NovaColors.lightOutline;

    return Dismissible(
      key: Key(note.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: NovaColors.error.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: NovaColors.error,
          size: 28,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title row with pin
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          note.title.isEmpty ? 'Untitled' : note.title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (note.isPinned)
                        GestureDetector(
                          onTap: onPinToggle,
                          child: Icon(
                            Icons.push_pin_rounded,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                    ],
                  ),

                  if (note.content.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      note.content,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? NovaColors.darkOnSurfaceVariant
                                : NovaColors.lightOnSurfaceVariant,
                            height: 1.4,
                          ),
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Date
                  Text(
                    _formatDate(note.updatedAt),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isDark
                              ? NovaColors.darkOnSurfaceVariant.withValues(alpha: 0.6)
                              : NovaColors.lightOnSurfaceVariant.withValues(alpha: 0.6),
                          fontSize: 10,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${date.day}/${date.month}/${date.year}';
  }
}
