import 'package:flutter/material.dart';
import 'package:nova_assistant/core/theme/app_colors.dart';

import '../../domain/entities/alarm.dart';
import 'package:nova_assistant/core/widgets/nova_card.dart';

/// Card widget displaying a single alarm with time, label, repeat days, and toggle
class AlarmCard extends StatelessWidget {
  final Alarm alarm;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const AlarmCard({
    super.key,
    required this.alarm,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

  static const List<String> _dayLabels = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];

  String _formatTime(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0
        ? 12
        : hour > 12
            ? hour - 12
            : hour;
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final timeColor = alarm.isEnabled
        ? (isDark ? NovaColors.darkOnBackground : NovaColors.lightOnBackground)
        : (isDark
            ? NovaColors.darkOnSurfaceVariant
            : NovaColors.lightOnSurfaceVariant);

    return Dismissible(
      key: ValueKey(alarm.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: NovaColors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: NovaColors.error, size: 28),
      ),
      child: NovaCard(
        onTap: onTap,
        enableGlow: alarm.isEnabled,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            // Time & label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatTime(alarm.hour, alarm.minute),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: timeColor,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1.5,
                    ),
                  ),
                  if (alarm.label != null && alarm.label!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      alarm.label!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? NovaColors.darkOnSurfaceVariant
                            : NovaColors.lightOnSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (alarm.repeatDays != null &&
                      alarm.repeatDays!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(7, (index) {
                        final isActive = alarm.repeatDays!.contains(index);
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Text(
                            _dayLabels[index],
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isActive
                                  ? NovaColors.primary
                                  : (isDark
                                      ? NovaColors.darkOnSurfaceVariant
                                          .withValues(alpha: 0.4)
                                      : NovaColors.lightOnSurfaceVariant
                                          .withValues(alpha: 0.4)),
                              fontWeight: isActive
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ],
              ),
            ),
            // Toggle switch
            Switch(
              value: alarm.isEnabled,
              onChanged: onToggle,
            ),
          ],
        ),
      ),
    );
  }
}
