import 'dart:ui';

import 'package:logger/logger.dart';

class AppLogger {
  static late Logger _logger;

  static void init() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
    );
  }

  // Performance monitoring
  static void performance(String message) {
    _logger.i('🚀 PERFORMANCE: $message');
  }

  // API monitoring
  static void apiCall(String endpoint, {int? statusCode, int? responseTime}) {
    _logger.i('🌐 API: $endpoint | Status: $statusCode | Time: ${responseTime}ms');
  }

  // User interaction tracking
  static void userAction(String action) {
    _logger.i('👆 USER: $action');
  }

  // UI state changes
  static void uiState(String widget, String state) {
    _logger.i('🎨 UI: $widget -> $state');
  }

  // Standard logging methods
  static void debug(String message) => _logger.d(message);
  static void info(String message) => _logger.i(message);
  static void warning(String message) => _logger.w(message);
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }
}

// Performance monitoring mixin
mixin PerformanceMonitorMixin {
  void monitorWidgetBuild(String widgetName, VoidCallback buildFunction) {
    final stopwatch = Stopwatch()..start();
    buildFunction();
    stopwatch.stop();

    if (stopwatch.elapsedMilliseconds > 16) { // More than one frame
      AppLogger.warning(
          'SLOW BUILD: $widgetName took ${stopwatch.elapsedMilliseconds}ms'
      );
    }
  }

  Future<T> monitorAsyncOperation<T>(
      String operationName,
      Future<T> Function() operation,
      ) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await operation();
      stopwatch.stop();
      AppLogger.performance(
          '$operationName completed in ${stopwatch.elapsedMilliseconds}ms'
      );
      return result;
    } catch (e) {
      stopwatch.stop();
      AppLogger.error(
        '$operationName failed after ${stopwatch.elapsedMilliseconds}ms',
        e,
      );
      rethrow;
    }
  }
}