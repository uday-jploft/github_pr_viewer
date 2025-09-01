import 'package:github_pr_viewer/core/utils/common_exports.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? token;
  final String? error;
  final String? username;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.token,
    this.error,
    this.username,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? token,
    String? error,
    String? username,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      token: token ?? this.token,
      error: error,
      username: username ?? this.username,
    );
  }
}

// Auth provider
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _initializeAuth();
  }

  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(),
  );

  Future<void> _initializeAuth() async {
    state = state.copyWith(isLoading: true);

    try {
      AppLogger.info('🔐 Initializing authentication...');

      // Check for stored token
      final token = await _secureStorage.read(key: 'github_token');
      final username = await _secureStorage.read(key: 'username');

      if (token != null && username != null) {
        AppLogger.info('✅ Found stored credentials for user: $username');
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          token: token,
          username: username,
        );
      } else {
        AppLogger.info('ℹ️ No stored credentials found');
        state = state.copyWith(isLoading: false);
      }
    } catch (e, stackTrace) {
      AppLogger.error('❌ Error initializing auth', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize authentication',
      );
    }
  }

  Future<bool> login(String username, String password) async {
    if (username.isEmpty) {
      state = state.copyWith(error: 'Username is required');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    AppLogger.userAction('Login attempt for user: $username');

    try {
      // Simulate API call delay for realistic UX
      await Future.delayed(const Duration(milliseconds: 1500));

      // Generate fake token (in real app, this would come from API)
      final fakeToken = 'ghp_${DateTime.now().millisecondsSinceEpoch}abc123';

      // Store credentials securely
      await _secureStorage.write(key: 'github_token', value: fakeToken);
      await _secureStorage.write(key: 'username', value: username);

      // Also store in shared preferences for easy access
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_username', username);
      await prefs.setInt('login_timestamp', DateTime.now().millisecondsSinceEpoch);

      AppLogger.info('✅ Login successful for user: $username');
      AppLogger.info('🔑 Token stored: ${fakeToken.substring(0, 10)}...');

      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        token: fakeToken,
        username: username,
        error: null,
      );

      return true;
    } catch (e, stackTrace) {
      AppLogger.error('❌ Login failed for user: $username', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: 'Login failed. Please try again.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    try {
      AppLogger.userAction('User logout initiated');

      // Clear secure storage
      await _secureStorage.deleteAll();

      // Clear shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('last_username');
      await prefs.remove('login_timestamp');

      AppLogger.info('✅ Logout successful - all credentials cleared');

      state = const AuthState();
    } catch (e, stackTrace) {
      AppLogger.error('❌ Error during logout', e, stackTrace);
      state = state.copyWith(error: 'Failed to logout properly');
    }
  }

  Future<String?> getStoredToken() async {
    try {
      final token = await _secureStorage.read(key: 'github_token');
      if (token != null) {
        AppLogger.info('🔑 Retrieved stored token: ${token.substring(0, 10)}...');
      }
      return token;
    } catch (e) {
      AppLogger.error('❌ Error retrieving stored token', e);
      return null;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider instances
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
      (ref) => AuthNotifier(),
);

// Convenience providers
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final authTokenProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).token;
});

final currentUsernameProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).username;
});

// Token monitoring service
class TokenMonitoringService {
  static Future<Map<String, dynamic>> getTokenInfo() async {
    const storage = FlutterSecureStorage();

    try {
      final token = await storage.read(key: 'github_token');
      final username = await storage.read(key: 'username');
      final prefs = await SharedPreferences.getInstance();
      final loginTimestamp = prefs.getInt('login_timestamp');

      final info = {
        'has_token': token != null,
        'token_length': token?.length ?? 0,
        'username': username,
        'login_time': loginTimestamp != null
            ? DateTime.fromMillisecondsSinceEpoch(loginTimestamp).toIso8601String()
            : null,
        'token_preview': token != null ? '${token.substring(0, 10)}...' : null,
      };

      AppLogger.info('🔍 Token info retrieved: $info');
      return info;
    } catch (e) {
      AppLogger.error('❌ Error getting token info', e);
      return {'error': e.toString()};
    }
  }

  static Future<bool> validateTokenFormat(String? token) async {
    if (token == null || token.isEmpty) return false;

    // Basic token format validation
    final isValid = token.length >= 20 &&
        (token.startsWith('ghp_') || token.startsWith('github_pat_'));

    AppLogger.info('🔒 Token validation: ${isValid ? 'VALID' : 'INVALID'}');
    return isValid;
  }
}

// providers/pull_requests_provider.dart


// Repository provider to store current repo
final repositoryProvider = StateProvider<String>((ref) => 'flutter/flutter');

// Pull requests provider
final pullRequestsProvider = FutureProvider<List<PullRequest>>((ref) async {
  final authState = ref.watch(authProvider);
  final repository = ref.watch(repositoryProvider);

  if (!authState.isAuthenticated || authState.token == null) {
    throw Exception('Not authenticated');
  }

  final repoParts = repository.split('/');
  if (repoParts.length != 2) {
    throw Exception('Invalid repository format. Use: owner/repo');
  }

  return GitHubApiService.getPullRequests(
    owner: repoParts[0],
    repo: repoParts[1],
    token: authState.token!,
  );
});

// Updated auth_provider.dart - Add this method to AuthNotifier class
extension AuthNotifierExtension on AuthNotifier {
  Future<bool> loginWithToken(String username, String token) async {
    if (username.isEmpty || token.isEmpty) {
      state = state.copyWith(error: 'Username and token are required');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    AppLogger.userAction('Login attempt with token for user: $username');

    try {
      // Validate token with GitHub API
      final isValidToken = await GitHubApiService.validateToken(token);

      if (!isValidToken) {
        state = state.copyWith(
          isLoading: false,
          error: 'Invalid GitHub token. Please check your token.',
        );
        return false;
      }

      // Store credentials securely
      await AuthNotifier._secureStorage.write(key: 'github_token', value: token);
      await AuthNotifier._secureStorage.write(key: 'username', value: username);

      // Also store in shared preferences for easy access
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_username', username);
      await prefs.setInt('login_timestamp', DateTime.now().millisecondsSinceEpoch);

      AppLogger.info('✅ Login successful for user: $username');
      AppLogger.info('🔑 Token validated and stored');

      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        token: token,
        username: username,
        error: null,
      );

      return true;
    } catch (e, stackTrace) {
      AppLogger.error('❌ Login failed for user: $username', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: 'Login failed. Please check your credentials.',
      );
      return false;
    }
  }
}