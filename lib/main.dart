import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:audio_service/audio_service.dart';
import 'data/models/ambience_model.dart';
import 'data/models/journal_entry_model.dart';
import 'features/player/services/audio_handler.dart';
import 'router.dart';
import 'shared/theme/app_theme.dart';
import 'shared/theme/theme_provider.dart';

// Global audio handler instance
late ArvyaxAudioHandler audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(AmbienceModelAdapter());
  Hive.registerAdapter(JournalEntryModelAdapter());

  // Initialize audio service for background playback
  audioHandler = await AudioService.init(
    builder: () => ArvyaxAudioHandler(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.arvyax.audio',
      androidNotificationChannelName: 'ArvyaX Audio',
      androidNotificationOngoing: false,
      androidStopForegroundOnPause: true,
    ),
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ProviderScope(child: ArvyaXApp()));
}

class ArvyaXApp extends ConsumerWidget {
  const ArvyaXApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'ArvyaX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      themeAnimationDuration: Duration.zero,
      routerConfig: appRouter,
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: const _IOSScrollBehavior(),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

class _IOSScrollBehavior extends ScrollBehavior {
  const _IOSScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }
}
