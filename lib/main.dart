import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/services/database_service.dart';
import 'core/services/notification_service.dart';
import 'features/assistant/presentation/controllers/conversation_controller.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register navigation callback for the assistant controller
  onAssistantNavigate = (path) => appRouter.push(path);

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0A0A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize core services
  await DatabaseService.instance.database;
  await NotificationService.instance.initialize();

  runApp(
    const ProviderScope(
      child: NovaApp(),
    ),
  );
}
