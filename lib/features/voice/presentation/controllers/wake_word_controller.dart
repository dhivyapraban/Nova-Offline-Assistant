import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/platform_channel_service.dart';
import '../widgets/google_assistant_overlay.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import 'voice_controller.dart';

class WakeWordController extends StateNotifier<bool> with WidgetsBindingObserver {
  final Ref _ref;
  static const _channel = MethodChannel('com.nova.nova_assistant/system');

  WakeWordController(this._ref) : super(false) {
    _init();
  }

  void _init() {
    WidgetsBinding.instance.addObserver(this);

    // Set up MethodChannel listener to intercept native wake-word callbacks
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onWakeWordTriggered') {
        _triggerWake();
      }
    });

    // Query native state on cold startup to check if app was launched via wake-word
    _checkPendingTrigger();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPendingTrigger();
    }
  }

  Future<void> _checkPendingTrigger() async {
    // Delay slightly to allow the view hierarchy to fully resume
    await Future.delayed(const Duration(milliseconds: 600));
    try {
      final triggered = await PlatformChannelService.instance.checkPendingVoiceTrigger();
      if (triggered) {
        _triggerWake();
      }
    } catch (_) {}
  }

  void _triggerWake() {
    // Bring system out of active processing/recording if in progress
    try {
      _ref.read(voiceControllerProvider.notifier).stopListening();
    } catch (_) {}

    final context = appRouter.routerDelegate.navigatorKey.currentContext;
    if (context != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => GoogleAssistantOverlay(),
      );
    }
  }
}

// === Providers ===

final wakeWordControllerProvider = StateNotifierProvider<WakeWordController, bool>((ref) {
  return WakeWordController(ref);
});
