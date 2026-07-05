import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:nova_assistant/core/theme/app_colors.dart';

/// Animated search bar for notes
class NoteSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String initialValue;

  const NoteSearchBar({
    super.key,
    required this.onChanged,
    this.initialValue = '',
  });

  @override
  State<NoteSearchBar> createState() => _NoteSearchBarState();
}

class _NoteSearchBarState extends State<NoteSearchBar> {
  late final TextEditingController _controller;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _isExpanded = widget.initialValue.isNotEmpty;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? NovaColors.darkSurfaceVariant : NovaColors.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _isExpanded
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.4)
              : (isDark ? NovaColors.darkOutline : NovaColors.lightOutline),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(
            Icons.search_rounded,
            size: 20,
            color: _isExpanded
                ? Theme.of(context).colorScheme.primary
                : (isDark ? NovaColors.darkOnSurfaceVariant : NovaColors.lightOnSurfaceVariant),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              onTap: () => setState(() => _isExpanded = true),
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Search notes...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? NovaColors.darkOnSurfaceVariant
                          : NovaColors.lightOnSurfaceVariant,
                    ),
              ),
            ),
          ),
          if (_controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _controller.clear();
                widget.onChanged('');
                setState(() => _isExpanded = false);
                FocusScope.of(context).unfocus();
              },
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: isDark
                      ? NovaColors.darkOnSurfaceVariant
                      : NovaColors.lightOnSurfaceVariant,
                ),
              ),
            ),
          const SizedBox(width: 6),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: -0.1, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }
}
