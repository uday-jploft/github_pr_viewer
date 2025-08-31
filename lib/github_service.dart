import 'dart:convert';
import 'package:github_pr_viewer/data/models/pull_request.dart';
import 'package:http/http.dart' as http;
import '../../../../core/utils/app_logger.dart';

class GitHubService {
  static const String baseUrl = 'https://api.github.com';

  static Future<List<PullRequest>> getPullRequests({
    required String owner,
    required String repo,
    required String token,
  }) async {
    try {
      AppLogger.info('🔍 Fetching pull requests for $owner/$repo');

      final url = Uri.parse('$baseUrl/repos/$owner/$repo/pulls');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'Flutter-GitHub-PR-Viewer',
        },
      );

      AppLogger.info('📡 GitHub API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final pullRequests = jsonData
            .map((json) => PullRequest.fromJson(json))
            .toList();

        AppLogger.info('✅ Successfully fetched ${pullRequests.length} pull requests');
        return pullRequests;
      } else if (response.statusCode == 401) {
        throw Exception('Invalid GitHub token. Please check your credentials.');
      } else if (response.statusCode == 404) {
        throw Exception('Repository not found. Please check owner/repo names.');
      } else if (response.statusCode == 403) {
        throw Exception('Rate limit exceeded or insufficient permissions.');
      } else {
        throw Exception('Failed to fetch pull requests: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('❌ Error fetching pull requests', e);
      rethrow;
    }
  }

  static Future<bool> validateToken(String token) async {
    try {
      final url = Uri.parse('$baseUrl/user');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'Flutter-GitHub-PR-Viewer',
        },
      );


      return response.statusCode == 200;
    } catch (e) {
      AppLogger.error('❌ Error validating token', e);
      return false;
    }
  }
}