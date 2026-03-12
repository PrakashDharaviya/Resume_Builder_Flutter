import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../auth/domain/entities/user.dart';

/// Screen that checks user role after successful authentication
/// and routes them to the appropriate dashboard.
/// Also handles blocked user detection.
class AuthCheckScreen extends StatefulWidget {
  final User user;

  const AuthCheckScreen({super.key, required this.user});

  @override
  State<AuthCheckScreen> createState() => AuthCheckScreenState();
}

class AuthCheckScreenState extends State<AuthCheckScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController animController;
  late Animation<double> scaleAnim;

  @override
  void initState() {
    super.initState();
    animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    scaleAnim = CurvedAnimation(
      parent: animController,
      curve: Curves.elasticOut,
    );
    animController.forward();

    // Delay briefly to show animation, then route
    Future.delayed(const Duration(milliseconds: 1200), handleRouting);
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }

  void handleRouting() {
    if (!mounted) return;

    if (widget.user.isBlocked) {
      showBlockedDialog();
      return;
    }

    if (widget.user.isAdmin) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.adminDashboard, (_) => false);
    } else {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.dashboard, (_) => false);
    }
  }

  void showBlockedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.block_rounded, color: Colors.red, size: 40),
        ),
        title: const Text(
          'Account Blocked',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Your account has been blocked by an administrator. '
          'Please contact support for assistance.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Go to Login',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: Center(
        child: ScaleTransition(
          scale: scaleAnim,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF34D399)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  widget.user.isAdmin
                      ? Icons.admin_panel_settings_rounded
                      : Icons.person_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome, ${widget.user.displayName}!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.user.isAdmin
                    ? 'Redirecting to Admin Panel...'
                    : 'Setting up your workspace...',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 28),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(Color(0xFF10B981)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
