import 'package:flutter/material.dart';
import 'package:resumebuilder/core/constants/app_colors.dart';
import 'package:resumebuilder/core/constants/app_routes.dart';
import 'package:resumebuilder/core/constants/app_strings.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<double> scaleAnimation;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    animationController.forward();

    _navigateFromLaunchContext();
  }

  String? _extractResetCodeFromUri(Uri uri) {
    final oobCode = uri.queryParameters['oobCode'];
    final mode = uri.queryParameters['mode'];
    if (oobCode != null && oobCode.isNotEmpty) {
      if (mode == null || mode == 'resetPassword') {
        return oobCode;
      }
    }

    final fragment = uri.fragment;
    if (fragment.contains('oobCode=')) {
      final fragmentAsUri = Uri.tryParse('https://dummy/$fragment');
      final fragmentCode = fragmentAsUri?.queryParameters['oobCode'];
      final fragmentMode = fragmentAsUri?.queryParameters['mode'];
      if (fragmentCode != null && fragmentCode.isNotEmpty) {
        if (fragmentMode == null || fragmentMode == 'resetPassword') {
          return fragmentCode;
        }
      }
    }

    return null;
  }

  String? _getLaunchResetCode() {
    final baseCode = _extractResetCodeFromUri(Uri.base);
    if (baseCode != null) {
      return baseCode;
    }

    final defaultRouteName =
        WidgetsBinding.instance.platformDispatcher.defaultRouteName;
    final routeUri = Uri.tryParse(defaultRouteName);
    if (routeUri != null) {
      return _extractResetCodeFromUri(routeUri);
    }

    return null;
  }

  void _navigateFromLaunchContext() {
    final launchResetCode = _getLaunchResetCode();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted || _hasNavigated) {
        return;
      }
      _hasNavigated = true;

      if (launchResetCode != null && launchResetCode.isNotEmpty) {
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.resetPassword,
          arguments: launchResetCode,
        );
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Center(
          child: AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: fadeAnimation,
                child: ScaleTransition(
                  scale: scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.description_outlined,
                            size: 64,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // App Name
                      const Text(
                        AppStrings.appName,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Tagline
                      const Text(
                        AppStrings.appTagline,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.white,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
