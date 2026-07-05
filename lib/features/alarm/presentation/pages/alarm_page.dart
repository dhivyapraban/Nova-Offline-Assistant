import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nova_assistant/core/theme/app_colors.dart';
import '../controllers/alarm_controller.dart';
import '../widgets/alarm_card.dart';
import '../widgets/alarm_time_picker.dart';

/// Main alarm page displaying all alarms with add/toggle/delete functionality
class AlarmPage extends ConsumerWidget {
  const AlarmPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarmsAsync = ref.watch(alarmControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Sort alarms',
            onPressed: () {
              // Future: sort options
            },
          ),
        ],
      ),
      body: alarmsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: NovaColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load alarms',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    ref.read(alarmControllerProvider.notifier).loadAlarms(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (alarms) {
          if (alarms.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.alarm_off_rounded,
                    size: 72,
                    color: isDark
                        ? NovaColors.darkOnSurfaceVariant.withValues(alpha: 0.3)
                        : NovaColors.lightOnSurfaceVariant
                            .withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No alarms set',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isDark
                          ? NovaColors.darkOnSurfaceVariant
                          : NovaColors.lightOnSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to create a new alarm',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? NovaColors.darkOnSurfaceVariant
                              .withValues(alpha: 0.6)
                          : NovaColors.lightOnSurfaceVariant
                              .withValues(alpha: 0.6),
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .scale(begin: const Offset(0.9, 0.9)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: alarms.length,
            itemBuilder: (context, index) {
              final alarm = alarms[index];
              return AlarmCard(
                alarm: alarm,
                onToggle: (enabled) {
                  ref
                      .read(alarmControllerProvider.notifier)
                      .toggleAlarm(alarm.id, enabled);
                },
                onTap: () async {
                  final result = await AlarmTimePicker.show(
                    context,
                    initialHour: alarm.hour,
                    initialMinute: alarm.minute,
                    initialLabel: alarm.label,
                    initialRepeatDays: alarm.repeatDays,
                  );
                  if (result != null) {
                    ref
                        .read(alarmControllerProvider.notifier)
                        .updateAlarm(alarm.copyWith(
                          hour: result.hour,
                          minute: result.minute,
                          label: result.label,
                          repeatDays: result.repeatDays,
                        ));
                  }
                },
                onDelete: () {
                  ref
                      .read(alarmControllerProvider.notifier)
                      .deleteAlarm(alarm.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Alarm deleted'),
                      action: SnackBarAction(
                        label: 'Undo',
                        textColor: NovaColors.primary,
                        onPressed: () {
                          ref
                              .read(alarmControllerProvider.notifier)
                              .createAlarm(
                                hour: alarm.hour,
                                minute: alarm.minute,
                                label: alarm.label,
                                repeatDays: alarm.repeatDays,
                              );
                        },
                      ),
                    ),
                  );
                },
              )
                  .animate()
                  .fadeIn(
                    duration: 400.ms,
                    delay: (50 * index).ms,
                  )
                  .slideX(
                    begin: 0.05,
                    duration: 400.ms,
                    delay: (50 * index).ms,
                    curve: Curves.easeOutCubic,
                  );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await AlarmTimePicker.show(context);
          if (result != null) {
            ref.read(alarmControllerProvider.notifier).createAlarm(
                  hour: result.hour,
                  minute: result.minute,
                  label: result.label,
                  repeatDays: result.repeatDays,
                );
          }
        },
        child: const Icon(Icons.add_alarm_rounded),
      )
          .animate()
          .scale(
            begin: const Offset(0, 0),
            duration: 400.ms,
            delay: 200.ms,
            curve: Curves.easeOutBack,
          ),
    );
  }
}
