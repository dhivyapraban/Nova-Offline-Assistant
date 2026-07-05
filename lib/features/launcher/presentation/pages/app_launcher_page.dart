import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/installed_app.dart';

final launcherControllerProvider = StateNotifierProvider<LauncherController, LauncherState>((ref) => LauncherController());

class LauncherState {
  final List<InstalledApp> apps;
  final bool isLoading;
  final String searchQuery;
  const LauncherState({this.apps = const [], this.isLoading = false, this.searchQuery = ''});
  LauncherState copyWith({List<InstalledApp>? apps, bool? isLoading, String? searchQuery}) =>
    LauncherState(apps: apps ?? this.apps, isLoading: isLoading ?? this.isLoading, searchQuery: searchQuery ?? this.searchQuery);
}

class LauncherController extends StateNotifier<LauncherState> {
  static const _channel = MethodChannel('com.nova.nova_assistant/launcher');
  LauncherController() : super(const LauncherState(isLoading: true)) { _loadApps(); }

  Future<void> _loadApps() async {
    try {
      final result = await _channel.invokeMethod('getInstalledApps');
      final apps = (result as List).map((map) => InstalledApp(
        packageName: map['packageName'] as String,
        appName: map['appName'] as String,
        versionName: map['versionName'] as String?,
      )).toList();
      apps.sort((a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));
      state = state.copyWith(apps: apps, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> launchApp(String packageName) async {
    try { await _channel.invokeMethod('launchApp', {'packageName': packageName}); } catch (_) {}
  }

  void search(String query) => state = state.copyWith(searchQuery: query);
}

class AppLauncherPage extends ConsumerWidget {
  const AppLauncherPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(launcherControllerProvider);
    final theme = Theme.of(context);
    final filtered = state.searchQuery.isEmpty ? state.apps
      : state.apps.where((a) => a.appName.toLowerCase().contains(state.searchQuery.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('App Launcher')),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(16), child: TextField(
          decoration: InputDecoration(hintText: 'Search apps...', prefixIcon: const Icon(Icons.search_rounded),
            filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
          onChanged: (v) => ref.read(launcherControllerProvider.notifier).search(v),
        )),
        Expanded(
          child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : filtered.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.apps_rounded, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('No apps found', style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                ]))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.75),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final app = filtered[i];
                    return InkWell(
                      onTap: () => ref.read(launcherControllerProvider.notifier).launchApp(app.packageName),
                      borderRadius: BorderRadius.circular(12),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Container(width: 48, height: 48,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                            color: theme.colorScheme.surfaceContainerHighest),
                          child: Center(child: Text(app.appName.isNotEmpty ? app.appName[0].toUpperCase() : '?',
                            style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary)))),
                        const SizedBox(height: 8),
                        Text(app.appName, style: theme.textTheme.labelSmall, maxLines: 2,
                          overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                      ]),
                    ).animate().fadeIn(duration: 200.ms, delay: Duration(milliseconds: i * 20));
                  }),
        ),
      ]),
    );
  }
}
