import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:nova_assistant/core/theme/theme_provider.dart';
import '../controllers/settings_controller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:nova_assistant/features/ai_engine/presentation/controllers/ai_engine_controller.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  String _appVersion = '';
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() => _appVersion = '${info.version} (${info.buildNumber})');
    } catch (_) {
      setState(() => _appVersion = '1.0.0');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final settingsAsync = ref.watch(settingsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (settings) {
          _nameController.text = settings.assistantName;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Appearance
              _sectionHeader('Appearance', theme).animate().fadeIn(duration: 300.ms),
              Card(
                child: Column(children: [
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Toggle between dark and light theme'),
                    secondary: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
                    value: isDark,
                    onChanged: (_) => ref.read(themeModeProvider.notifier).toggleTheme(),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.palette_rounded),
                    title: const Text('Theme'),
                    subtitle: Text(isDark ? 'Dark (Nothing OS)' : 'Light'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showThemePicker(context, ref),
                  ),
                ]),
              ).animate().fadeIn(duration: 300.ms, delay: 50.ms),



              // Assistant
              _sectionHeader('Assistant', theme).animate().fadeIn(duration: 300.ms, delay: 200.ms),
              Card(
                child: Column(children: [
                  ListTile(
                    leading: const Icon(Icons.person_rounded),
                    title: const Text('Assistant Name'),
                    subtitle: Text(settings.assistantName),
                    trailing: const Icon(Icons.edit_rounded),
                    onTap: () => _showNameDialog(context, ref),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.spatial_audio_off_rounded),
                    title: const Text('Wake Word'),
                    subtitle: const Text("Listen for 'Hey Nova' in background"),
                    value: settings.wakeWordEnabled,
                    onChanged: (val) async {
                      if (val) {
                        // 1. Verify microphone permission
                        final micStatus = await Permission.microphone.request();
                        if (!micStatus.isGranted) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Microphone permission is required for the Wake Word feature.")),
                            );
                          }
                          return;
                        }

                        // 2. Verify "Draw over other apps" permission to allow background activity launches
                        final alertStatus = await Permission.systemAlertWindow.request();
                        if (!alertStatus.isGranted) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Draw over other apps permission is required to wake the app from background.")),
                            );
                          }
                          return;
                        }
                      }
                      ref.read(settingsControllerProvider.notifier).toggleWakeWord(val);
                      if (val) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Wake word background service started. Say 'Hey Nova'.")),
                          );
                        }
                      }
                    },
                  ),
                ]),
              ).animate().fadeIn(duration: 300.ms, delay: 250.ms),

              const SizedBox(height: 24),

              // AI Model
              _sectionHeader('AI Model', theme).animate().fadeIn(duration: 300.ms, delay: 300.ms),
              Consumer(builder: (context, ref, _) {
                final aiState = ref.watch(aiEngineControllerProvider);
                final statusColor = switch (aiState.status) {
                  AIEngineStatus.ready when aiState.isLLMActive => theme.colorScheme.primary,
                  AIEngineStatus.loading => Colors.orange,
                  AIEngineStatus.error => Colors.red,
                  _ => Colors.grey,
                };
                final statusIcon = switch (aiState.status) {
                  AIEngineStatus.ready when aiState.isLLMActive => Icons.check_circle_rounded,
                  AIEngineStatus.loading => Icons.hourglass_top_rounded,
                  AIEngineStatus.error => Icons.error_rounded,
                  _ => Icons.radio_button_unchecked_rounded,
                };
                return Card(
                  child: Column(children: [
                    ListTile(
                      leading: Icon(Icons.memory_rounded, color: statusColor),
                      title: const Text('Model Engine'),
                      subtitle: Text(aiState.statusMessage),
                      trailing: Icon(statusIcon, color: statusColor, size: 20),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.folder_rounded),
                      title: const Text('Model Path (GGUF)'),
                      subtitle: Text(settings.modelPath != null && settings.modelPath!.isNotEmpty
                          ? settings.modelPath!.split('/').last.split('\\').last
                          : 'Tap to select a .gguf model file'),
                      trailing: aiState.status == AIEngineStatus.loading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.chevron_right_rounded),
                      onTap: aiState.status == AIEngineStatus.loading
                          ? null
                          : () => _pickModelFile(context, ref),
                    ),
                    if (aiState.isLLMActive) ...[  
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.link_off_rounded),
                        title: const Text('Unload Model'),
                        subtitle: const Text('Switch back to rule-based engine'),
                        onTap: () => ref.read(aiEngineControllerProvider.notifier).unloadModel(),
                      ),
                    ],
                  ]),
                );
              }).animate().fadeIn(duration: 300.ms, delay: 350.ms),

              const SizedBox(height: 24),

              // Storage
              _sectionHeader('Storage', theme).animate().fadeIn(duration: 300.ms, delay: 400.ms),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.delete_sweep_rounded),
                  title: const Text('Clear All Data'),
                  subtitle: const Text('Delete all notes, timers, and history'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showClearDataDialog(context, ref),
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 450.ms),

              const SizedBox(height: 24),

              // About
              _sectionHeader('About', theme).animate().fadeIn(duration: 300.ms, delay: 500.ms),
              Card(
                child: Column(children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded),
                    title: const Text('Nova Assistant'),
                    subtitle: Text('Version $_appVersion'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.code_rounded),
                    title: const Text('Architecture'),
                    subtitle: const Text('Clean Architecture + Riverpod'),
                  ),
                ]),
              ).animate().fadeIn(duration: 300.ms, delay: 550.ms),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionHeader(String title, ThemeData theme) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title,
            style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary, fontWeight: FontWeight.w600, letterSpacing: 1)),
      );

  void _showThemePicker(BuildContext context, WidgetRef ref) {
    final current = ref.read(themeModeProvider);
    showDialog(
        context: context,
        builder: (context) => SimpleDialog(
              title: const Text('Select Theme'),
              children: [
                ListTile(
                  leading: Icon(Icons.dark_mode_rounded,
                      color: current == ThemeMode.dark ? Theme.of(context).colorScheme.primary : null),
                  title: const Text('Dark'),
                  selected: current == ThemeMode.dark,
                  onTap: () {
                    ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.light_mode_rounded,
                      color: current == ThemeMode.light ? Theme.of(context).colorScheme.primary : null),
                  title: const Text('Light'),
                  selected: current == ThemeMode.light,
                  onTap: () {
                    ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings_brightness_rounded,
                      color: current == ThemeMode.system ? Theme.of(context).colorScheme.primary : null),
                  title: const Text('System'),
                  selected: current == ThemeMode.system,
                  onTap: () {
                    ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system);
                    Navigator.pop(context);
                  },
                ),
              ],
            ));
  }


  void _showNameDialog(BuildContext context, WidgetRef ref) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Assistant Name'),
              content: TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                FilledButton(
                    onPressed: () {
                      ref.read(settingsControllerProvider.notifier).updateAssistantName(_nameController.text);
                      Navigator.pop(context);
                    },
                    child: const Text('Save')),
              ],
            ));
  }

  Future<void> _pickModelFile(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      if (!mounted) return;
      // 1. Save path to persistent settings
      await ref.read(settingsControllerProvider.notifier).updateModelPath(path);
      // 2. Immediately load the model in the AI engine
      await ref.read(aiEngineControllerProvider.notifier).loadModel(path);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Loading model: ${path.split("/").last.split("\\\\").last}')),
        );
      }
    }
  }

  void _showClearDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Clear All Data?'),
              content: const Text(
                  'This will permanently delete all your notes, timers, reminders, and conversation history.'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
                  onPressed: () async {
                    await ref.read(settingsControllerProvider.notifier).resetSettings();
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('All data cleared successfully.')),
                      );
                    }
                  },
                  child: const Text('Clear'),
                ),
              ],
            ));
  }
}
