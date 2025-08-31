// lib/features/pr/presentation/widgets/pr_search_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/app_logger.dart';
import '../providers/pr_provider.dart';

class PRSearchBar extends ConsumerStatefulWidget {
  const PRSearchBar({super.key});

  @override
  ConsumerState<PRSearchBar> createState() => _PRSearchBarState();
}

class _PRSearchBarState extends ConsumerState<PRSearchBar>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _focusNode.addListener(() {
      setState(() {
        _isExpanded = _focusNode.hasFocus;
      });

      if (_focusNode.hasFocus) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(prSearchQueryProvider.notifier).state = query;
    AppLogger.userAction('Search query updated: "$query"');
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
    _focusNode.unfocus();
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: _isExpanded
                  ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
                  : null,
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'Search pull requests...',
                prefixIcon: Icon(
                  Icons.search,
                  color: _isExpanded
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                )
                    : null,
                filled: true,
                fillColor: _isExpanded
                    ? theme.colorScheme.surface
                    : theme.colorScheme.surfaceVariant.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
            ),
          ),
        );
      },
    );
  }
}

// lib/features/pr/presentation/widgets/pr_empty_state.dart
class PREmptyState extends StatefulWidget {
  const PREmptyState({super.key});

  @override
  State<PREmptyState> createState() => _PREmptyStateState();
}

class _PREmptyStateState extends State<PREmptyState>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    AppLogger.uiState('PREmptyState', 'showing');

    _bounceController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 20.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _bounceAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -_bounceAnimation.value),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withOpacity(0.2),
                            theme.colorScheme.secondary.withOpacity(0.2),
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.inbox_outlined,
                        size: 60,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              Text(
                'No Pull Requests Found',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'This repository doesn\'t have any open pull requests yet.\nCreate your first PR to get started!',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  AppLogger.userAction('Create PR button tapped from empty state');
                  // Navigate to GitHub or show instructions
                },
                icon: const Icon(Icons.add),
                label: const Text('Create Pull Request'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// lib/features/pr/presentation/widgets/pr_error_state.dart
class PRErrorState extends StatefulWidget {
  final String error;
  final VoidCallback onRetry;

  const PRErrorState({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  State<PRErrorState> createState() => _PRErrorStateState();
}

class _PRErrorStateState extends State<PRErrorState>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    AppLogger.uiState('PRErrorState', 'showing error: ${widget.error}');

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticOut,
    ));

    _shakeController.forward();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            final shake = (_shakeAnimation.value * 4 * 3.14159);
            return Transform.translate(
              offset: Offset(4 * (1 - _shakeAnimation.value) *
                  (shake.remainder(6.28318) > 3.14159 ? -1 : 1), 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.error.withOpacity(0.1),
                    ),
                    child: Icon(
                      Icons.error_outline,
                      size: 60,
                      color: theme.colorScheme.error,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Oops! Something went wrong',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.error.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      widget.error,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 32),

                  ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      AppLogger.userAction('Retry button tapped from error state');
                      widget.onRetry();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}