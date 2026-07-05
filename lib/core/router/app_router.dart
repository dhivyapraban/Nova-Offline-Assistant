import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/pages/home_page.dart';
import '../../features/assistant/presentation/pages/conversation_page.dart';
import '../../features/voice/presentation/pages/voice_assistant_page.dart';
import '../../features/notes/presentation/pages/notes_list_page.dart';
import '../../features/notes/presentation/pages/note_editor_page.dart';
import '../../features/timer/presentation/pages/timer_page.dart';
import '../../features/alarm/presentation/pages/alarm_page.dart';
import '../../features/reminder/presentation/pages/reminder_page.dart';
import '../../features/todo/presentation/pages/todo_page.dart';
import '../../features/music/presentation/pages/music_library_page.dart';
import '../../features/music/presentation/pages/now_playing_page.dart';
import '../../features/files/presentation/pages/file_explorer_page.dart';
import '../../features/study/presentation/pages/study_home_page.dart';
import '../../features/study/presentation/pages/pdf_viewer_page.dart';
import '../../features/launcher/presentation/pages/app_launcher_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

/// App router configuration with GoRouter
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      pageBuilder: (context, state) => _buildPageTransition(
        context,
        state,
        const HomePage(),
      ),
    ),
    GoRoute(
      path: '/conversation',
      name: 'conversation',
      pageBuilder: (context, state) => _buildPageTransition(
        context,
        state,
        const ConversationPage(),
      ),
    ),
    GoRoute(
      path: '/voice',
      name: 'voice',
      pageBuilder: (context, state) => _buildPageTransition(
        context,
        state,
        const VoiceAssistantPage(),
      ),
    ),
    GoRoute(
      path: '/notes',
      name: 'notes',
      pageBuilder: (context, state) => _buildPageTransition(
        context,
        state,
        const NotesListPage(),
      ),
    ),
    GoRoute(
      path: '/notes/editor',
      name: 'note-editor',
      pageBuilder: (context, state) {
        final noteId = state.uri.queryParameters['id'];
        return _buildPageTransition(
          context,
          state,
          NoteEditorPage(noteId: noteId),
        );
      },
    ),
    GoRoute(
      path: '/timer',
      name: 'timer',
      pageBuilder: (context, state) => _buildPageTransition(
        context,
        state,
        const TimerPage(),
      ),
    ),
    GoRoute(
      path: '/alarm',
      name: 'alarm',
      pageBuilder: (context, state) => _buildPageTransition(
        context,
        state,
        const AlarmPage(),
      ),
    ),
    GoRoute(
      path: '/reminder',
      name: 'reminder',
      pageBuilder: (context, state) => _buildPageTransition(
        context,
        state,
        const ReminderPage(),
      ),
    ),
    GoRoute(
      path: '/todo',
      name: 'todo',
      pageBuilder: (context, state) => _buildPageTransition(
        context,
        state,
        const TodoPage(),
      ),
    ),
    GoRoute(
      path: '/music',
      name: 'music',
      pageBuilder: (context, state) => _buildPageTransition(
        context,
        state,
        const MusicLibraryPage(),
      ),
    ),
    GoRoute(
      path: '/music/now-playing',
      name: 'now-playing',
      pageBuilder: (context, state) => _buildPageTransition(
        context,
        state,
        const NowPlayingPage(),
      ),
    ),
    GoRoute(
      path: '/files',
      name: 'files',
      pageBuilder: (context, state) => _buildPageTransition(
        context,
        state,
        const FileExplorerPage(),
      ),
    ),
    GoRoute(
      path: '/study',
      name: 'study',
      pageBuilder: (context, state) => _buildPageTransition(
        context,
        state,
        const StudyHomePage(),
      ),
    ),
    GoRoute(
      path: '/study/pdf',
      name: 'pdf-viewer',
      pageBuilder: (context, state) {
        final filePath = state.uri.queryParameters['path'] ?? '';
        return _buildPageTransition(
          context,
          state,
          PdfViewerPage(filePath: filePath),
        );
      },
    ),
    GoRoute(
      path: '/launcher',
      name: 'launcher',
      pageBuilder: (context, state) => _buildPageTransition(
        context,
        state,
        const AppLauncherPage(),
      ),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      pageBuilder: (context, state) => _buildPageTransition(
        context,
        state,
        const SettingsPage(),
      ),
    ),
  ],
);

/// Smooth slide + fade page transition
CustomTransitionPage _buildPageTransition(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final offsetAnimation = Tween<Offset>(
        begin: const Offset(0.05, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      ));

      final fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      ));

      return FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(
          position: offsetAnimation,
          child: child,
        ),
      );
    },
  );
}
