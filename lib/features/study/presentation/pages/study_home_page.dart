import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';

class StudyHomePage extends ConsumerWidget {
  const StudyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Study Assistant')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
          if (result != null && result.files.single.path != null && context.mounted) {
            context.push('/study/pdf?path=${Uri.encodeComponent(result.files.single.path!)}');
          }
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Open PDF'),
      ).animate().scale(delay: 300.ms, duration: 400.ms, curve: Curves.elasticOut),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.school_rounded, size: 80, color: theme.colorScheme.primary.withValues(alpha: 0.3))
            .animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 24),
          Text('Study Assistant', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text('Open a PDF to start studying.\nOffline RAG will be available in a future update.',
              textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5)))),
        ]).animate().fadeIn(duration: 400.ms),
      ),
    );
  }
}
