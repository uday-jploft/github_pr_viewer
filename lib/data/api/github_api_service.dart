// lib/data/api/github_api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/utils/app_logger.dart';
import '../models/pull_request.dart';

class GitHubApiService {
  static const String baseUrl = 'https://api.github.com';
  static const String owner = 'uday-jploft'; // Replace with actual username
  static const String repo = 'github_pr_viewer'; // Replace with actual repo name
  // https://github.com/uday-jploft/realm_trainer
  final http.Client _client;

  GitHubApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch all pull requests
  Future<List<PullRequest>> fetchPullRequests({
    String? token,
    String state = 'open',
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      AppLogger.info('🔄 Fetching pull requests for $owner/$repo');

      final uri = Uri.parse('$baseUrl/repos/$owner/$repo/pulls').replace(
        queryParameters: {
          'state': state,
          'sort': 'updated',
          'direction': 'desc',
          'per_page': '50',
        },
      );

      final headers = <String, String>{
        'Accept': 'application/vnd.github.v3+json',
        'User-Agent': 'GitHub-PR-Viewer-Flutter-App',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      AppLogger.info('📡 Making API request to: ${uri.toString()}');

      final response = await _client.get(uri, headers: headers);
      stopwatch.stop();

      AppLogger.apiCall(
        'GET /repos/$owner/$repo/pulls',
        statusCode: response.statusCode,
        responseTime: stopwatch.elapsedMilliseconds,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final pullRequests =
        jsonList.map((json) => PullRequest.fromJson(json)).toList();

        AppLogger.info('✅ Successfully fetched ${pullRequests.length} pull requests');
        return pullRequests;
      } else {
        final errorMessage = _handleApiError(response);
        AppLogger.error('❌ API Error: $errorMessage');
        throw GitHubApiException(errorMessage, response.statusCode);
      }
    } on SocketException catch (e) {
      stopwatch.stop();
      AppLogger.error(
          '🌐 Network error after ${stopwatch.elapsedMilliseconds}ms', e);
      throw GitHubApiException(
        'No internet connection. Please check your network and try again.',
        0,
      );
    } on FormatException catch (e) {
      stopwatch.stop();
      AppLogger.error('📝 JSON parsing error', e);
      throw GitHubApiException('Invalid response format from GitHub API', 0);
    } catch (e, stackTrace) {
      stopwatch.stop();
      AppLogger.error(
        '💥 Unexpected error after ${stopwatch.elapsedMilliseconds}ms',
        e,
        stackTrace,
      );
      throw GitHubApiException('An unexpected error occurred: ${e.toString()}', 0);
    }
  }

  /// Fetch single PR details
  Future<PullRequest> fetchPullRequestDetails(
      int prNumber, {
        String? token,
      }) async {
    final stopwatch = Stopwatch()..start();

    try {
      AppLogger.info('🔍 Fetching details for PR #$prNumber');

      final uri = Uri.parse('$baseUrl/repos/$owner/$repo/pulls/$prNumber');

      final headers = <String, String>{
        'Accept': 'application/vnd.github.v3+json',
        'User-Agent': 'GitHub-PR-Viewer-Flutter-App',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await _client.get(uri, headers: headers);
      stopwatch.stop();

      AppLogger.apiCall(
        'GET /repos/$owner/$repo/pulls/$prNumber',
        statusCode: response.statusCode,
        responseTime: stopwatch.elapsedMilliseconds,
      );

      if (response.statusCode == 200) {
        final pullRequest = PullRequest.fromJson(json.decode(response.body));
        AppLogger.info('✅ Successfully fetched PR #$prNumber details');
        return pullRequest;
      } else {
        final errorMessage = _handleApiError(response);
        AppLogger.error('❌ API Error for PR #$prNumber: $errorMessage');
        throw GitHubApiException(errorMessage, response.statusCode);
      }
    } on SocketException catch (e) {
      stopwatch.stop();
      AppLogger.error(
          '🌐 Network error after ${stopwatch.elapsedMilliseconds}ms', e);
      throw GitHubApiException(
        'No internet connection. Please check your network and try again.',
        0,
      );
    } on FormatException catch (e) {
      stopwatch.stop();
      AppLogger.error('📝 JSON parsing error', e);
      throw GitHubApiException('Invalid response format from GitHub API', 0);
    } catch (e, stackTrace) {
      stopwatch.stop();
      AppLogger.error(
        '💥 Unexpected error after ${stopwatch.elapsedMilliseconds}ms',
        e,
        stackTrace,
      );
      throw GitHubApiException('An unexpected error occurred: ${e.toString()}', 0);
    }
  }

  String _handleApiError(http.Response response) {
    switch (response.statusCode) {
      case 401:
        return 'Authentication required. Please check your token.';
      case 403:
        return 'Access forbidden. You may have hit the rate limit.';
      case 404:
        return 'Repository not found. Please check the owner and repo name.';
      case 422:
        return 'Invalid request parameters.';
      case 500:
      case 502:
      case 503:
        return 'GitHub server error. Please try again later.';
      default:
        try {
          final errorData = json.decode(response.body);
          return errorData['message'] ?? 'Unknown error occurred';
        } catch (_) {
          return 'HTTP ${response.statusCode}: ${response.reasonPhrase}';
        }
    }
  }

  void dispose() {
    _client.close();
  }
}

/// Exception class
class GitHubApiException implements Exception {
  final String message;
  final int statusCode;

  GitHubApiException(this.message, this.statusCode);

  @override
  String toString() => 'GitHubApiException: $message (Status: $statusCode)';
}

/// API monitoring and caching service
class ApiMonitoringService {
  static final Map<String, DateTime> _lastRequestTimes = {};
  static final Map<String, int> _requestCounts = {};

  static void logRequest(String endpoint) {
    final now = DateTime.now();
    _lastRequestTimes[endpoint] = now;
    _requestCounts[endpoint] = (_requestCounts[endpoint] ?? 0) + 1;

    AppLogger.info(
        '📊 API Stats - $endpoint: ${_requestCounts[endpoint]} requests');
  }

  static bool shouldCache(String endpoint) {
    final lastRequest = _lastRequestTimes[endpoint];
    if (lastRequest == null) return false;

    final timeSinceLastRequest = DateTime.now().difference(lastRequest);
    return timeSinceLastRequest.inMinutes < 5; // Cache for 5 minutes
  }

  static Map<String, dynamic> getApiStats() {
    return {
      'total_requests': _requestCounts.values.fold(0, (a, b) => a + b),
      'endpoints_hit': _requestCounts.keys.length,
      'request_counts': Map.from(_requestCounts),
      'last_request_times':
      _lastRequestTimes.map((key, value) => MapEntry(key, value.toIso8601String())),
    };
  }
}
