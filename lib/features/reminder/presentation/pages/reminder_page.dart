import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nova_assistant/core/utils/extensions.dart';
import '../../domain/entities/reminder.dart';
import '../controllers/reminder_controller.dart';

class ReminderPage extends ConsumerWidget {
  const ReminderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reminderControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add_rounded),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (reminders) {
          if (reminders.isEmpty) {
            return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.notifications_none_rounded, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text('No reminders', style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
            ]));
          }
          final upcoming = reminders.where((r) => !r.isCompleted).toList();
          final completed = reminders.where((r) => r.isCompleted).toList();
          return ListView(padding: const EdgeInsets.all(16), children: [
            if (upcoming.isNotEmpty) ...[
              Text('Upcoming', style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
              const SizedBox(height: 8),
              ...upcoming.asMap().entries.map((e) => _buildCard(context, ref, e.value, e.key)),
            ],
            if (completed.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Completed', style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
              const SizedBox(height: 8),
              ...completed.asMap().entries.map((e) => _buildCard(context, ref, e.value, e.key + upcoming.length)),
            ],
          ]);
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context, WidgetRef ref, Reminder reminder, int index) {
    final theme = Theme.of(context);
    return Dismissible(
      key: Key(reminder.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => ref.read(reminderControllerProvider.notifier).deleteReminder(reminder.id),
      background: Container(
        alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: theme.colorScheme.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
        child: Icon(Icons.delete_rounded, color: theme.colorScheme.error),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Checkbox(
            value: reminder.isCompleted,
            onChanged: (_) => ref.read(reminderControllerProvider.notifier).toggleComplete(reminder.id),
            activeColor: theme.colorScheme.primary,
          ),
          title: Text(reminder.title, style: TextStyle(
            decoration: reminder.isCompleted ? TextDecoration.lineThrough : null)),
          subtitle: Text(reminder.remindAt.formattedFull, style: theme.textTheme.bodySmall),
          trailing: reminder.description != null ? const Icon(Icons.notes_rounded, size: 18) : null,
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: index * 50));
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    String title = '';
    String description = '';
    DateTime selectedDate = DateTime.now().add(const Duration(hours: 1));

    showDialog(context: context, builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('New Reminder'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(decoration: const InputDecoration(labelText: 'Title'), onChanged: (v) => title = v),
          const SizedBox(height: 12),
          TextField(decoration: const InputDecoration(labelText: 'Description (optional)'), onChanged: (v) => description = v),
          const SizedBox(height: 16),
          Row(children: [
            const Icon(Icons.calendar_today_rounded, size: 18),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () async {
                final date = await showDatePicker(context: context,
                  initialDate: selectedDate, firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)));
                if (date != null) {
                  final time = await showTimePicker(context: context,
                    initialTime: TimeOfDay.fromDateTime(selectedDate));
                  if (time != null) {
                    setState(() => selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute));
                  }
                }
              },
              child: Text(selectedDate.formattedFull),
            ),
          ]),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (title.isNotEmpty) {
                ref.read(reminderControllerProvider.notifier).addReminder(
                  title: title, description: description.isEmpty ? null : description, remindAt: selectedDate);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ));
  }
}
