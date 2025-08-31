// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'core/theme/app_theme.dart';
import 'core/utils/app_logger.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logging for monitoring
  AppLogger.init();

  // Performance monitoring
  final stopwatch = Stopwatch()..start();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // System UI styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  stopwatch.stop();
  AppLogger.performance('App initialization took: ${stopwatch.elapsedMilliseconds}ms');

  runApp(
    const ProviderScope(
      child: GitHubPRViewerApp(),
    ),
  );
}

class GitHubPRViewerApp extends ConsumerWidget {
  const GitHubPRViewerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);
    final initialRoute = ref.watch(initialRouteProvider);

    return MaterialApp(
      title: 'GitHub PR Viewer',
      debugShowCheckedModeBanner: false,

      // Theme Configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // Routing
      routes: router,
      initialRoute: initialRoute,

      // Performance monitoring
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(
              1,
            ),
          ),
          child: child ?? Container(),
        );
      },
    );
  }
}

// Theme mode provider for dark/light mode switching
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
      (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system);

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    AppLogger.info('Theme changed to: $state');
  }

  void setTheme(ThemeMode mode) {
    state = mode;
    AppLogger.info('Theme set to: $mode');
  }
}