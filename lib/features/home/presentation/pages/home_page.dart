import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_microphone_button.dart';
import 'package:nova_assistant/features/voice/presentation/widgets/google_assistant_overlay.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isListening = false;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    if (hour < 21) return 'Good Evening';
    return 'Good Night';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.transparent,
              title: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: NovaColors.primaryGradient,
                    ),
                    child: const Center(
                      child: Text(
                        'N',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Nova',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.history_rounded),
                  onPressed: () => context.push('/conversation'),
                  tooltip: 'Conversation History',
                ),
                IconButton(
                  icon: const Icon(Icons.settings_rounded),
                  onPressed: () => context.push('/settings'),
                  tooltip: 'Settings',
                ),
              ],
            ),

            // Greeting Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.05),
                    const SizedBox(height: 4),
                    Text(
                      'How can I help you?',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(begin: -0.05),
                  ],
                ),
              ),
            ),

            // Mic Button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: AnimatedMicrophoneButton(
                    isListening: _isListening,
                    size: 80,
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => GoogleAssistantOverlay(),
                      );
                    },
                  ),
                ).animate().scale(
                  begin: const Offset(0.8, 0.8),
                  duration: 500.ms,
                  curve: Curves.elasticOut,
                ),
              ),
            ),

            // Quick Actions Label
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Text(
                  'Quick Actions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
              ),
            ),

            // Quick Actions Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                delegate: SliverChildListDelegate(
                  _buildQuickActions(context, isDark),
                ),
              ),
            ),

            // Secondary Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Text(
                  'More Tools',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 500.ms),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                delegate: SliverChildListDelegate(
                  _buildSecondaryActions(context, isDark),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildQuickActions(BuildContext context, bool isDark) {
    final actions = [
      _QuickActionData(
        icon: Icons.sticky_note_2_rounded,
        label: 'Notes',
        route: '/notes',
        color: const Color(0xFF00E676),
        delay: 350,
      ),
      _QuickActionData(
        icon: Icons.timer_rounded,
        label: 'Timer',
        route: '/timer',
        color: const Color(0xFF00B0FF),
        delay: 400,
      ),
      _QuickActionData(
        icon: Icons.music_note_rounded,
        label: 'Music',
        route: '/music',
        color: const Color(0xFFFF6D00),
        delay: 450,
      ),
      _QuickActionData(
        icon: Icons.folder_rounded,
        label: 'Files',
        route: '/files',
        color: const Color(0xFFAA00FF),
        delay: 500,
      ),
      _QuickActionData(
        icon: Icons.school_rounded,
        label: 'Study',
        route: '/study',
        color: const Color(0xFFFFD600),
        delay: 550,
      ),
      _QuickActionData(
        icon: Icons.notifications_active_rounded,
        label: 'Reminders',
        route: '/reminder',
        color: const Color(0xFFFF1744),
        delay: 600,
      ),
    ];

    return actions.map((action) {
      return _QuickActionTile(
        icon: action.icon,
        label: action.label,
        color: action.color,
        isDark: isDark,
        onTap: () => context.push(action.route),
      ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: action.delay))
        .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack);
    }).toList();
  }

  List<Widget> _buildSecondaryActions(BuildContext context, bool isDark) {
    final actions = [
      _QuickActionData(
        icon: Icons.alarm_rounded,
        label: 'Alarm',
        route: '/alarm',
        color: const Color(0xFF00E5FF),
        delay: 650,
      ),
      _QuickActionData(
        icon: Icons.checklist_rounded,
        label: 'Todo',
        route: '/todo',
        color: const Color(0xFF76FF03),
        delay: 700,
      ),
      _QuickActionData(
        icon: Icons.apps_rounded,
        label: 'Apps',
        route: '/launcher',
        color: const Color(0xFFE040FB),
        delay: 750,
      ),
    ];

    return actions.map((action) {
      return _QuickActionTile(
        icon: action.icon,
        label: action.label,
        color: action.color,
        isDark: isDark,
        onTap: () => context.push(action.route),
      ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: action.delay))
        .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack);
    }).toList();
  }
}

class _QuickActionData {
  final IconData icon;
  final String label;
  final String route;
  final Color color;
  final int delay;

  const _QuickActionData({
    required this.icon,
    required this.label,
    required this.route,
    required this.color,
    required this.delay,
  });
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? NovaColors.darkSurface
                : NovaColors.lightSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? NovaColors.darkOutline
                  : NovaColors.lightOutline,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 26,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
