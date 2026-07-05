import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/router/app_router.dart';
import 'features/voice/presentation/controllers/wake_word_controller.dart';

/// Root application widget
class NovaApp extends ConsumerWidget {
  const NovaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    // Force global wake word listener instantiation on startup
    ref.watch(wakeWordControllerProvider);

    return MaterialApp.router(
      title: 'Nova Assistant',
      debugShowCheckedModeBanner: false,
      theme: NovaTheme.lightTheme,
      darkTheme: NovaTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
