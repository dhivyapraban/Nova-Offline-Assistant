import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nova_assistant/core/utils/extensions.dart';
import '../controllers/timer_controller.dart';

class TimerPage extends ConsumerWidget {
  const TimerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timers = ref.watch(timerControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Timers')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTimerDialog(context, ref),
        child: const Icon(Icons.add_rounded),
      ).animate().scale(delay: 300.ms, duration: 400.ms, curve: Curves.elasticOut),
      body: timers.isEmpty
          ? Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.timer_rounded, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text('No active timers', style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
              ]),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: timers.length,
              itemBuilder: (context, index) {
                final timer = timers[index];
                final progress = timer.durationSeconds > 0
                    ? timer.remainingSeconds / timer.durationSeconds : 0.0;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(children: [
                      if (timer.label != null)
                        Text(timer.label!, style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 120, height: 120,
                        child: Stack(alignment: Alignment.center, children: [
                          CircularProgressIndicator(
                            value: progress, strokeWidth: 6,
                            backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.2),
                          ),
                          Text(Duration(seconds: timer.remainingSeconds).formatted,
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold,
                              color: timer.remainingSeconds <= 0 ? theme.colorScheme.error : null)),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        IconButton(
                          icon: Icon(timer.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded),
                          onPressed: timer.remainingSeconds > 0
                              ? () => ref.read(timerControllerProvider.notifier).togglePause(timer.id) : null,
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => ref.read(timerControllerProvider.notifier).removeTimer(timer.id),
                        ),
                      ]),
                    ]),
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: index * 100));
              },
            ),
    );
  }

  void _showAddTimerDialog(BuildContext context, WidgetRef ref) {
    int minutes = 5;
    String label = '';
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('New Timer'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Label (optional)'),
              onChanged: (v) => label = v,
            ),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              IconButton(icon: const Icon(Icons.remove), onPressed: () {
                if (minutes > 1) setState(() => minutes--);
              }),
              Text('$minutes min', style: Theme.of(context).textTheme.headlineSmall),
              IconButton(icon: const Icon(Icons.add), onPressed: () => setState(() => minutes++)),
            ]),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                ref.read(timerControllerProvider.notifier).addTimer(
                  seconds: minutes * 60, label: label.isEmpty ? null : label);
                Navigator.pop(context);
              },
              child: const Text('Start'),
            ),
          ],
        ),
      ),
    );
  }
}
