import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resumebuilder/core/constants/app_colors.dart';
import 'package:resumebuilder/core/utils/validators.dart';
import 'package:resumebuilder/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:resumebuilder/features/auth/presentation/bloc/auth_event.dart';
import 'package:resumebuilder/features/auth/presentation/bloc/auth_state.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onSendResetLink() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        ForgotPasswordRequestedEvent(email: _emailController.text.trim()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is ForgotPasswordSuccess) {
            setState(() {
              _emailSent = true;
            });
            _animController.forward();
          } else if (state is ForgotPasswordError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ForgotPasswordLoading;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: _emailSent
                    ? _buildSuccessView(context)
                    : _buildEmailForm(context, isLoading),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Email Entry Form ────────────────────────────────────────────────────

  Widget _buildEmailForm(BuildContext context, bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.lock_reset,
            size: 80,
            color: AppColors.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Reset Your Password',
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Enter your registered email address.\nWe will send a password reset link to your email.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 16),
          // Google Sign-In note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: Colors.blue[700]),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Signed in with Google? Use the "Sign in with Google" button on the login page instead.',
                    style: TextStyle(fontSize: 12.5, color: Colors.blue[800]),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            enabled: !isLoading,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: Validators.validateEmail,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: isLoading ? null : _onSendResetLink,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : const Text('Send Reset Link'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: isLoading
                ? null
                : () => Navigator.of(context).pop(),
            child: const Text('Back to Login'),
          ),
        ],
      ),
    );
  }

  // ── Beautiful Success View ──────────────────────────────────────────────

  Widget _buildSuccessView(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated check circle
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mark_email_read_outlined,
                size: 56,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 28),

            Text(
              'Check Your Email! 📧',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Email display chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.email, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _emailController.text.trim(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'We\'ve sent a password reset link to your email.\n'
              'Open your inbox, click the link, and set your new password.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryLight,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),

            // Helpful tips
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline,
                          size: 18, color: Colors.amber[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Tips',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Check your spam/junk folder if you don\'t see the email\n'
                    '• The link expires in 1 hour\n'
                    '• You can request a new link if needed',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.amber[900],
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Resend button
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _emailSent = false;
                });
                _animController.reset();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Send Again'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Back to login
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
