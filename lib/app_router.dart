import 'package:flutter/material.dart';
import 'admin/presentation/pages/admin_dashboard.dart';
import 'admin/presentation/pages/analytics_page.dart';
import 'admin/presentation/pages/announcements_page.dart';
import 'admin/presentation/pages/ats_settings_page.dart';
import 'admin/presentation/pages/manage_templates_page.dart';
import 'admin/presentation/pages/manage_users_page.dart';
import 'auth/auth_check_screen.dart';
import 'auth/login_page.dart';
import 'auth/register_page.dart';
import 'core/constants/app_routes.dart';
import 'features/ats_analysis/presentation/pages/ats_analysis_page.dart';
import 'features/auth/domain/entities/user.dart' as auth_user;
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/resume/domain/entities/resume.dart';
import 'features/resume/presentation/pages/pdf_export_page.dart';
import 'user/presentation/pages/ats_result_page.dart';
import 'user/presentation/pages/resume_editor_page.dart';
import 'user/presentation/pages/resume_preview_page.dart';
import 'user/presentation/pages/template_selection_page.dart';
import 'user/presentation/pages/user_dashboard.dart';
import 'user/presentation/pages/user_profile_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());

      case AppRoutes.dashboard:
        return MaterialPageRoute(builder: (_) => const UserDashboard());

      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const UserProfilePage());

      case AppRoutes.atsAnalysis:
        final resumeData = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ATSAnalysisPage(resumeData: resumeData ?? {}),
        );

      case AppRoutes.atsResult:
        final score = settings.arguments as double?;
        return MaterialPageRoute(
          builder: (_) => ATSResultPage(score: score ?? 78),
        );

      case AppRoutes.createResume:
        return MaterialPageRoute(builder: (_) => const _CreateResumePage());

      case AppRoutes.resumeEditor:
        final resumeArg = settings.arguments as Resume?;
        return MaterialPageRoute(
          builder: (_) => ResumeEditorPage(resume: resumeArg),
        );

      case AppRoutes.editResume:
        final resumeArg = settings.arguments as Resume?;
        return MaterialPageRoute(
          builder: (_) => ResumeEditorPage(resume: resumeArg),
        );

      case AppRoutes.templateSelection:
        return MaterialPageRoute(builder: (_) => const TemplateSelectionPage());

      case AppRoutes.resumePreview:
        final resume = settings.arguments as Resume?;
        if (resume == null) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('No resume data provided')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => ResumePreviewPage(resume: resume),
        );

      case AppRoutes.exportPDF:
        final resume = settings.arguments as Resume?;
        if (resume == null) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('No resume data provided')),
            ),
          );
        }
        return MaterialPageRoute(builder: (_) => PDFExportPage(resume: resume));

      case AppRoutes.authCheck:
        final user = settings.arguments as auth_user.User;
        return MaterialPageRoute(builder: (_) => AuthCheckScreen(user: user));

      case AppRoutes.adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboard());

      case AppRoutes.manageUsers:
        return MaterialPageRoute(builder: (_) => const ManageUsersPage());

      case AppRoutes.manageTemplates:
        return MaterialPageRoute(builder: (_) => const ManageTemplatesPage());

      case AppRoutes.atsSettings:
        return MaterialPageRoute(builder: (_) => const ATSSettingsPage());

      case AppRoutes.analytics:
        return MaterialPageRoute(builder: (_) => const AnalyticsPage());

      case AppRoutes.announcements:
        return MaterialPageRoute(builder: (_) => const AnnouncementsPage());

      case AppRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const _ForgotPasswordPage());

      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const _SettingsPage());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Route ${settings.name} not found')),
          ),
        );
    }
  }
}

class _ForgotPasswordPage extends StatelessWidget {
  const _ForgotPasswordPage();

  @override
  Widget build(BuildContext context) {
    final emailCtrl = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_reset, size: 80, color: Color(0xFF10B981)),
            const SizedBox(height: 24),
            const Text(
              'Reset Your Password',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Enter your email address and we\'ll send you a link to reset your password.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(
                labelText: 'Email Address',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password reset link sent to your email'),
                    ),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Send Reset Link'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Account'),
            subtitle: const Text('Manage your account settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Privacy'),
            subtitle: const Text('Privacy and security settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: const Text('App version 1.0.0'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'ResumeIQ',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2026 ResumeIQ',
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CreateResumePage extends StatelessWidget {
  const _CreateResumePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Resume')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.description_outlined,
                  size: 50,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Create New Resume',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Build your professional resume section by section.\nAdd education, experience, skills and more.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 36),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(
                  context,
                ).pushReplacementNamed(AppRoutes.resumeEditor),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Start Building'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
