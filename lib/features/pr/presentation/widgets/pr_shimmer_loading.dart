import 'package:github_pr_viewer/core/utils/common_exports.dart';
// import 'package:shimmer/shimmer.dart';

class PRShimmerLoading extends StatefulWidget {
  const PRShimmerLoading({super.key});

  @override
  State<PRShimmerLoading> createState() => _PRShimmerLoadingState();
}

class _PRShimmerLoadingState extends State<PRShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    AppLogger.uiState('PRShimmerLoading', 'showing');

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _controller,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildShimmerCard(theme, index),
          );
        },
      ),
    );
  }

  Widget _buildShimmerCard(ThemeData theme, int index) {
    return Shimmer.fromColors(
      baseColor: theme.brightness == Brightness.dark
          ? Colors.grey[800]!
          : Colors.grey[300]!,
      highlightColor: theme.brightness == Brightness.dark
          ? Colors.grey[700]!
          : Colors.grey[100]!,
      period: Duration(milliseconds: 1500 + (index * 100)),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 60,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              const SizedBox(height: 8),

              Container(
                width: MediaQuery.of(context).size.width * 0.7,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              const SizedBox(height: 6),

              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),

                      const SizedBox(height: 4),

                      Container(
                        width: 60,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  Container(
                    width: 50,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// lib/features/pr/presentation/widgets/pr_stats_card.dart
class PRStatsCard extends ConsumerWidget {
  const PRStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final stats = ref.watch(prStatsProvider);
    final prState = ref.watch(pullRequestProvider);

    if (prState.isFirstLoad || prState.pullRequests.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Repository Overview',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (prState.lastUpdated != null)
                  Text(
                    'Updated ${_formatLastUpdated(prState.lastUpdated!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            Builder(
              builder: (context) {
                print(stats);
                return Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        theme,
                        'Open PRs',
                        '${stats['open']}',
                        Icons.radio_button_unchecked,
                        const Color(0xFF28A745),
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        theme,
                        'Draft PRs',
                        '${stats['draft']}',
                        Icons.edit_outlined,
                        theme.colorScheme.outline,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        theme,
                        'Changes',
                        '+${stats['total_additions']} -${stats['total_deletions']}',
                        Icons.code,
                        theme.colorScheme.primary,
                      ),
                    ),
                  ],
                );
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      ThemeData theme,
      String label,
      String value,
      IconData icon,
      Color color,
      ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _formatLastUpdated(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}