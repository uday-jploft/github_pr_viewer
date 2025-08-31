// lib/core/monitoring/performance_monitor.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../utils/app_logger.dart';
import '../../data/api/github_api_service.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

// Performance metrics model
class PerformanceMetrics {
  final double memoryUsage;
  final double cpuUsage;
  final int frameRate;
  final int apiResponseTime;
  final int totalRequests;
  final DateTime timestamp;

  PerformanceMetrics({
    required this.memoryUsage,
    required this.cpuUsage,
    required this.frameRate,
    required this.apiResponseTime,
    required this.totalRequests,
    required this.timestamp,
  });
}

// Performance monitor provider
class PerformanceMonitor extends StateNotifier<PerformanceMetrics> {
  PerformanceMonitor() : super(
    PerformanceMetrics(
      memoryUsage: 0,
      cpuUsage: 0,
      frameRate: 60,
      apiResponseTime: 0,
      totalRequests: 0,
      timestamp: DateTime.now(),
    ),
  ) {
    _startMonitoring();
  }

  Timer? _monitoringTimer;
  final List<double> _frameRates = [];
  final List<int> _apiTimes = [];

  void _startMonitoring() {
    _monitoringTimer = Timer.periodic(
      const Duration(seconds: 2),
          (_) => _updateMetrics(),
    );
  }

  void _updateMetrics() {
    // Simulate performance metrics (in real app, use platform channels)
    final now = DateTime.now();
    final avgFrameRate = _frameRates.isEmpty ? 60 :
    _frameRates.reduce((a, b) => a + b) / _frameRates.length;
    final avgApiTime = _apiTimes.isEmpty ? 0 :
    _apiTimes.reduce((a, b) => a + b) ~/ _apiTimes.length;

    state = PerformanceMetrics(
      memoryUsage: 45.5 + (DateTime.now().millisecond % 10), // Simulated
      cpuUsage: 12.3 + (DateTime.now().millisecond % 5), // Simulated
      frameRate: avgFrameRate.round(),
      apiResponseTime: avgApiTime,
      totalRequests: ApiMonitoringService.getApiStats()['total_requests'] ?? 0,
      timestamp: now,
    );

    // Log performance warnings
    if (state.frameRate < 55) {
      AppLogger.warning('⚠️ Low frame rate detected: ${state.frameRate}fps');
    }
    if (state.apiResponseTime > 3000) {
      AppLogger.warning('⚠️ Slow API response: ${state.apiResponseTime}ms');
    }
  }

  void recordFrameRate(double fps) {
    _frameRates.add(fps);
    if (_frameRates.length > 30) _frameRates.removeAt(0);
  }

  void recordApiTime(int milliseconds) {
    _apiTimes.add(milliseconds);
    if (_apiTimes.length > 10) _apiTimes.removeAt(0);
  }

  @override
  void dispose() {
    _monitoringTimer?.cancel();
    super.dispose();
  }
}

final performanceMonitorProvider = StateNotifierProvider<PerformanceMonitor, PerformanceMetrics>(
      (ref) => PerformanceMonitor(),
);

// Debug performance overlay widget
class PerformanceOverlay extends ConsumerWidget {
  final Widget child;

  const PerformanceOverlay({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(performanceMonitorProvider);
    final theme = Theme.of(context);

    return Stack(
      children: [
        child,

        // Performance overlay (only show in debug mode)
        if (const bool.fromEnvironment('dart.vm.profile') == false)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 10,
            child: Material(
              color: theme.colorScheme.surface.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
              elevation: 4,
              child: Container(
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(maxWidth: 150),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Performance',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildMetricRow('FPS', '${metrics.frameRate}',
                        metrics.frameRate >= 55 ? Colors.green : Colors.red),
                    _buildMetricRow('Memory', '${metrics.memoryUsage.toStringAsFixed(1)}MB',
                        metrics.memoryUsage < 100 ? Colors.green : Colors.orange),
                    _buildMetricRow('API', '${metrics.apiResponseTime}ms',
                        metrics.apiResponseTime < 1000 ? Colors.green : Colors.red),
                    _buildMetricRow('Requests', '${metrics.totalRequests}', Colors.blue),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
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
      'last_visits': _routeVisits.map(
            (key, value) => MapEntry(key, value.toIso8601String()),
      ),
      'recent_history': _navigationHistory.take(10).map((e) => {
        'route': e.route,
        'timestamp': e.timestamp.toIso8601String(),
      }).toList(),
    };
  }

  static List<NavigationEvent> get navigationHistory => List.from(_navigationHistory);
}

class NavigationEvent {
  final String route;
  final DateTime timestamp;

  NavigationEvent(this.route, this.timestamp);
}