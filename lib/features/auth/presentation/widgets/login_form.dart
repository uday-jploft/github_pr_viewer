// lib/features/auth/presentation/widgets/login_form.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/app_logger.dart';
import '../providers/auth_provider.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  late AnimationController _buttonController;
  late Animation<double> _buttonScale;

  bool _obscurePassword = true;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _buttonScale = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));

    // Add listeners for form validation
    _usernameController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);

    // Pre-fill with demo credentials
    _usernameController.text = 'uday-jploft';
    _passwordController.text = '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';
    _validateForm();
  }

  @override
  void dispose() {
    _buttonController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _validateForm() {
    final isValid = _usernameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty;

    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Button press animation
    _buttonController.forward().then((_) {
      _buttonController.reverse();
    });

    AppLogger.userAction('Login form submitted');

    // final success = await ref.read(authProvider.notifier).login(
    //   _usernameController.text.trim(),
    //   _passwordController.text,
    // );

    final success = await ref.read(authProvider.notifier).loginWithToken(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );



    if (success) {
      HapticFeedback.mediumImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      // Error haptic feedback
      HapticFeedback.heavyImpact();
    }

  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Username Field
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: TextFormField(
                controller: _usernameController,
                focusNode: _usernameFocusNode,
                decoration: InputDecoration(
                  labelText: 'GitHub Username',
                  hintText: 'Enter your username',
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: theme.colorScheme.primary,
                  ),
                  suffixIcon: _usernameController.text.isNotEmpty
                      ? Icon(
                    Icons.check_circle,
                    color: theme.colorScheme.primary,
                  )
                      : null,
                ),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  _passwordFocusNode.requestFocus();
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Username is required';
                  }
                  if (value.trim().length < 3) {
                    return 'Username must be at least 3 characters';
                  }
                  return null;
                },
                onChanged: (value) {
                  AppLogger.userAction('Username field updated');
                },
              ),
            ),

            const SizedBox(height: 24),

            // Password Field
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: TextFormField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: theme.colorScheme.primary,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                      AppLogger.userAction('Password visibility toggled');
                    },
                  ),
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  if (_isFormValid) _handleLogin();
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  return null;
                },
                onChanged: (value) {
                  AppLogger.userAction('Password field updated');
                },
              ),
            ),

            const SizedBox(height: 32),

            // Login Button
            AnimatedBuilder(
              animation: _buttonScale,
              builder: (context, child) {
                return Transform.scale(
                  scale: _buttonScale.value,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: _isFormValid
                          ? LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      )
                          : null,
                      color: _isFormValid ? null : theme.disabledColor,
                      boxShadow: _isFormValid
                          ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ]
                          : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _isFormValid && !authState.isLoading
                            ? _handleLogin
                            : null,
                        child: Container(
                          alignment: Alignment.center,
                          child: authState.isLoading
                              ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Signing in...',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                              : Text(
                            'Sign In',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Demo Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Demo Mode',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Use any username and password to continue. This is a simulation for secure token handling demonstration.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}