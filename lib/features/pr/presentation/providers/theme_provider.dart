import 'package:github_pr_viewer/core/utils/common_exports.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
      (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system);

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    AppLogger.info('Theme changed to: $state');
  }
}