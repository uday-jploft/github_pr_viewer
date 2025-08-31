import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/app_logger.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/pr/presentation/screens/pr_list_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

// Simple navigation without go_router dependency
class AppRouter {
  static const String login = '/login';
  static const String pullRequests = '/pull-requests';
}

// Navigation service
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  static void navigateToLogin() {
    AppLogger.info('🧭 Navigating to login');
    navigatorKey.currentState?.pushReplacementNamed(AppRouter.login);
  }

  static void navigateToPullRequests() {
    AppLogger.info('🧭 Navigating to pull requests');
    navigatorKey.currentState?.pushReplacementNamed(AppRouter.pullRequests);
  }
}

// App router provider for simple navigation
final appRouterProvider = Provider<Map<String, WidgetBuilder>>((ref) {
  return {
    AppRouter.login: (context) {
      AppLogger.uiState('Router', 'Navigated to Login');
      return const LoginScreen();
    },
    AppRouter.pullRequests: (context) {
      AppLogger.uiState('Router', 'Navigated to PR List');
      return const PullRequestListScreen();
    },
  };
});

// Initial route provider
final initialRouteProvider = Provider<String>((ref) {
  final authState = ref.watch(authProvider);
  final route =
  authState.isAuthenticated ? AppRouter.pullRequests : AppRouter.login;
  AppLogger.info('🚀 Initial route determined: $route');
  return route;
});

// Navigation monitoring service
class NavigationMonitoringService {
  static final Map<String, DateTime> _routeVisits = {};
  static final Map<String, int> _routeCounts = {};
  static final List<NavigationEvent> _navigationHistory = [];

  static void logNavigation(String route) {
    final now = DateTime.now();
    _routeVisits[route] = now;
    _routeCounts[route] = (_routeCounts[route] ?? 0) + 1;

    _navigationHistory.add(NavigationEvent(route, now));
    if (_navigationHistory.length > 50) {
      _navigationHistory.removeAt(0);
    }

    AppLogger.info('🧭 Navigation to $route (visit #${_routeCounts[route]})');
  }

  static Map<String, dynamic> getNavigationStats() {
    return {
      'total_navigations': _routeCounts.values.fold(0, (a, b) => a + b),
      'unique_routes': _routeCounts.keys.length,
      'route_counts': Map.from(_routeCounts),
      'last_visits':
      _routeVisits.map((key, value) => MapEntry(key, value.toIso8601String())),
      'recent_history': _navigationHistory.take(10).map((e) => {
        'route': e.route,
        'timestamp': e.timestamp.toIso8601String(),
      }).toList(),
    };
  }

  static List<NavigationEvent> get navigationHistory =>
      List.from(_navigationHistory);
}

class NavigationEvent {
  final String route;
  final DateTime timestamp;

  NavigationEvent(this.route, this.timestamp);
}

// Custom route observer for monitoring
class RouteMonitoringObserver extends RouteObserver<ModalRoute<dynamic>> {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _logRouteChange('PUSH', route.settings.name);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _logRouteChange('POP', route.settings.name);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _logRouteChange('REPLACE', newRoute?.settings.name);
  }

  void _logRouteChange(String action, String? routeName) {
    final route = routeName ?? 'Unknown';
    AppLogger.info('🧭 Route $action: $route');
    NavigationMonitoringService.logNavigation('$action:$route');
  }
}
