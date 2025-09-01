

import 'package:github_pr_viewer/core/utils/common_exports.dart';

class PullRequestState {
  final List<PullRequest> pullRequests;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final DateTime? lastUpdated;
  final int totalCount;

  const PullRequestState({
    this.pullRequests = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.lastUpdated,
    this.totalCount = 0,
  });

  PullRequestState copyWith({
    List<PullRequest>? pullRequests,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    DateTime? lastUpdated,
    int? totalCount,
  }) {
    return PullRequestState(
      pullRequests: pullRequests ?? this.pullRequests,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      totalCount: totalCount ?? this.totalCount,
    );
  }

  bool get isEmpty => pullRequests.isEmpty && !isLoading;
  bool get hasData => pullRequests.isNotEmpty;
  bool get isFirstLoad => isLoading && pullRequests.isEmpty;
}

// Pull request notifier
class PullRequestNotifier extends StateNotifier<PullRequestState> {
  PullRequestNotifier(this._apiService) : super(const PullRequestState());

  final GitHubApiService _apiService;

  Future<void> fetchPullRequests({
    String? token,
    bool isRefresh = false,
  }) async {
    if (isRefresh) {
      state = state.copyWith(isRefreshing: true, error: null);
      AppLogger.userAction('Pull to refresh initiated');
    } else {
      state = state.copyWith(isLoading: true, error: null);
      AppLogger.info('🔄 Loading pull requests...');
    }

    try {
      final stopwatch = Stopwatch()..start();

      final pullRequests = await _apiService.fetchPullRequests(token: token);

      stopwatch.stop();
      AppLogger.performance(
          'Fetched ${pullRequests.length} PRs in ${stopwatch.elapsedMilliseconds}ms'
      );

      state = state.copyWith(
        pullRequests: pullRequests,
        isLoading: false,
        isRefreshing: false,
        error: null,
        lastUpdated: DateTime.now(),
        totalCount: pullRequests.length,
      );

      AppLogger.info('✅ Pull requests loaded successfully');

    } catch (e, stackTrace) {
      AppLogger.error('❌ Failed to fetch pull requests', e, stackTrace);

      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshPullRequests({String? token}) async {
    AppLogger.userAction('Manual refresh triggered');
    await fetchPullRequests(token: token, isRefresh: true);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  // Filter pull requests by state
  List<PullRequest> filterByState(String filterState) {
    return state.pullRequests
        .where((pr) => pr.state.toLowerCase() == filterState.toLowerCase())
        .toList();
  }

  // Search pull requests
  List<PullRequest> searchPullRequests(String query) {
    if (query.isEmpty) return state.pullRequests;

    final lowercaseQuery = query.toLowerCase();
    return state.pullRequests.where((pr) {
      return pr.title.toLowerCase().contains(lowercaseQuery) ||
          pr.author.login.toLowerCase().contains(lowercaseQuery) ||
          (pr.body?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }
}

// Provider instances
final gitHubApiServiceProvider = Provider<GitHubApiService>((ref) {
  return GitHubApiService();
});

final pullRequestProvider = StateNotifierProvider<PullRequestNotifier, PullRequestState>((ref) {
  final apiService = ref.watch(gitHubApiServiceProvider);
  return PullRequestNotifier(apiService);
});

// Convenience providers
final pullRequestsListProvider = Provider<List<PullRequest>>((ref) {
  return ref.watch(pullRequestProvider).pullRequests;
});

final isLoadingPRsProvider = Provider<bool>((ref) {
  return ref.watch(pullRequestProvider).isLoading;
});

final isRefreshingPRsProvider = Provider<bool>((ref) {
  return ref.watch(pullRequestProvider).isRefreshing;
});

final prErrorProvider = Provider<String?>((ref) {
  return ref.watch(pullRequestProvider).error;
});

final prStatsProvider = Provider<Map<String, int>>((ref) {
  final prs = ref.watch(pullRequestsListProvider);

  final stats = <String, int>{
    'total': prs.length,
    'open': prs.where((pr) => pr.state == 'open').length,
    'closed': prs.where((pr) => pr.state == 'closed').length,
    'draft': prs.where((pr) => pr.draft).length,
    'total_additions': prs.fold(0, (sum, pr) => sum + pr.additions),
    'total_deletions': prs.fold(0, (sum, pr) => sum + pr.deletions),
  };

  AppLogger.info('📊 PR Stats: $stats');
  return stats;
});

// Search provider
final prSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredPullRequestsProvider = Provider<List<PullRequest>>((ref) {
  final prs = ref.watch(pullRequestsListProvider);
  final searchQuery = ref.watch(prSearchQueryProvider);

  if (searchQuery.isEmpty) return prs;

  final filtered = prs.where((pr) {
    final query = searchQuery.toLowerCase();
    return pr.title.toLowerCase().contains(query) ||
        pr.author.login.toLowerCase().contains(query) ||
        (pr.body?.toLowerCase().contains(query) ?? false);
  }).toList();

  AppLogger.info('🔍 Search results: ${filtered.length}/${prs.length} PRs');
  return filtered;
});