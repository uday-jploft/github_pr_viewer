import 'package:github_pr_viewer/core/utils/common_exports.dart';

class PullRequestListScreen extends ConsumerStatefulWidget {
  const PullRequestListScreen({super.key});

  @override
  ConsumerState<PullRequestListScreen> createState() => _PullRequestListScreenState();
}

class _PullRequestListScreenState extends ConsumerState<PullRequestListScreen>
    with TickerProviderStateMixin {
  late AnimationController _listAnimationController;
  late AnimationController _fabAnimationController;

  final ScrollController _scrollController = ScrollController();
  bool _showFab = false;

  @override
  void initState() {
    super.initState();
    AppLogger.uiState('PullRequestListScreen', 'initialized');

    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPullRequests();
    });
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    _fabAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final shouldShowFab = _scrollController.offset > 200;
    if (shouldShowFab != _showFab) {
      setState(() {
        _showFab = shouldShowFab;
      });

      if (_showFab) {
        _fabAnimationController.forward();
      } else {
        _fabAnimationController.reverse();
      }
    }
  }

  Future<void> _loadPullRequests() async {
    final token = ref.read(authTokenProvider);
    await ref.read(pullRequestProvider.notifier).fetchPullRequests(token: token);
    _listAnimationController.forward();
  }

  Future<void> _refreshPullRequests() async {
    HapticFeedback.lightImpact();
    final token = ref.read(authTokenProvider);
    await ref.read(pullRequestProvider.notifier).refreshPullRequests(token: token);
  }

  void _scrollToTop() {
    HapticFeedback.lightImpact();
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prState = ref.watch(pullRequestProvider);
    final filteredPRs = ref.watch(filteredPullRequestsProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Pull Requests'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              theme.brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
              HapticFeedback.lightImpact();
            },
          ),

          // Logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // Token display (for demo purposes)
          if (authState.token != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Demo Token (Stored Securely)',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${authState.token!.substring(0, 15)}...',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Search bar
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: PRSearchBar(),
          ),

          // Stats card
          const Padding(
            padding: EdgeInsets.all(16),
            child: PRStatsCard(),
          ),

          // Pull requests list
          Expanded(
            child: _buildPRList(theme, prState, filteredPRs),
          ),
        ],
      ),

      // Floating action button
      floatingActionButton: ScaleTransition(
        scale: _fabAnimationController,
        child: FloatingActionButton(
          onPressed: _scrollToTop,
          backgroundColor: theme.colorScheme.primary,
          child: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildPRList(
      ThemeData theme,
      PullRequestState prState,
      List<PullRequest> filteredPRs,
      ) {
    // Error state
    if (prState.error != null && prState.pullRequests.isEmpty) {
      return PRErrorState(
        error: prState.error!,
        onRetry: _loadPullRequests,
      );
    }

    // Loading state (first load)
    if (prState.isFirstLoad) {
      return const PRShimmerLoading();
    }

    // Empty state
    if (prState.isEmpty) {
      return const PREmptyState();
    }

    // Pull requests list
    return RefreshIndicator(
      onRefresh: _refreshPullRequests,
      color: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surface,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Refresh indicator space
          SliverToBoxAdapter(
            child: prState.isRefreshing
                ? Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Refreshing...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            )
                : const SizedBox.shrink(),
          ),

          // Pull requests list
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final pr = filteredPRs[index];

                  return AnimatedBuilder(
                    animation: _listAnimationController,
                    builder: (context, child) {
                      final animationValue = Curves.easeOutCubic.transform(
                        (_listAnimationController.value - (index * 0.1))
                            .clamp(0.0, 1.0),
                      );

                      return Transform.translate(
                        offset: Offset(0, 50 * (1 - animationValue)),
                        child: Opacity(
                          opacity: animationValue,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: PRCard(
                              pullRequest: pr,
                              index: index,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                childCount: filteredPRs.length,
              ),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }
}

class PRListPerformanceMonitor {
  static final Map<String, Stopwatch> _timers = {};

  static void startTimer(String operation) {
    _timers[operation] = Stopwatch()..start();
  }

  static void endTimer(String operation) {
    final timer = _timers[operation];
    if (timer != null) {
      timer.stop();
      AppLogger.performance('$operation took ${timer.elapsedMilliseconds}ms');
      _timers.remove(operation);
    }
  }

  static void monitorListBuild(int itemCount) {
    if (itemCount > 20) {
      AppLogger.warning('Large list detected: $itemCount items');
    }
    AppLogger.performance('List rendered with $itemCount items');
  }
}