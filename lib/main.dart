import 'package:github_pr_viewer/core/utils/common_exports.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppLogger.init();

  final stopwatch = Stopwatch()..start();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  stopwatch.stop();
  AppLogger.performance('App initialization time: ${stopwatch.elapsedMilliseconds}ms');

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
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routes: router,
      initialRoute: initialRoute,
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

