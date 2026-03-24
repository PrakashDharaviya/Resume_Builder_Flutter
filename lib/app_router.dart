import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resumebuilder/admin/presentation/pages/admin_dashboard.dart';
import 'package:resumebuilder/admin/presentation/pages/analytics_page.dart';
import 'package:resumebuilder/admin/presentation/pages/announcements_page.dart';
import 'package:resumebuilder/admin/presentation/pages/ats_settings_page.dart';
import 'package:resumebuilder/admin/presentation/pages/manage_templates_page.dart';
import 'package:resumebuilder/admin/presentation/pages/manage_users_page.dart';
import 'package:resumebuilder/auth/auth_check_screen.dart';
import 'package:resumebuilder/auth/login_page.dart';
import 'package:resumebuilder/auth/register_page.dart';
import 'package:resumebuilder/core/constants/app_routes.dart';
import 'package:resumebuilder/features/admin/domain/entities/resume_template.dart';
import 'package:resumebuilder/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:resumebuilder/features/admin/presentation/pages/send_notification_page.dart';
import 'package:resumebuilder/features/admin/presentation/pages/template_preview_page.dart';
import 'package:resumebuilder/features/ats_analysis/presentation/bloc/ats_bloc.dart';
import 'package:resumebuilder/features/ats_analysis/presentation/pages/ats_analysis_page.dart';
import 'package:resumebuilder/features/auth/domain/entities/user.dart'
    as auth_user;
import 'package:resumebuilder/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:resumebuilder/features/auth/presentation/pages/reset_password_page.dart';
import 'package:resumebuilder/features/auth/presentation/pages/splash_page.dart';
import 'package:resumebuilder/features/resume/domain/entities/resume.dart';
import 'package:resumebuilder/features/resume/presentation/pages/pdf_export_page.dart';
import 'package:resumebuilder/injection_container.dart' as di;
import 'package:resumebuilder/user/presentation/pages/ats_result_page.dart';
import 'package:resumebuilder/user/presentation/pages/resume_editor_page.dart';
import 'package:resumebuilder/user/presentation/pages/resume_preview_page.dart';
import 'package:resumebuilder/user/presentation/pages/template_selection_page.dart';
import 'package:resumebuilder/user/presentation/pages/user_dashboard.dart';
import 'package:resumebuilder/user/presentation/pages/user_profile_page.dart';

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
          builder: (_) => BlocProvider<ATSBloc>(
            create: (_) => di.sl<ATSBloc>(),
            child: ATSAnalysisPage(resumeData: resumeData ?? {}),
          ),
        );

      case AppRoutes.atsResult:
        final score = settings.arguments as double?;
        return MaterialPageRoute(
          builder: (_) => BlocProvider<ATSBloc>(
            create: (_) => di.sl<ATSBloc>(),
            child: ATSResultPage(score: score ?? 78),
          ),
        );

      case AppRoutes.createResume:
        return MaterialPageRoute(builder: (_) => const CreateResumePage());

      case AppRoutes.resumeEditor:
        Resume? resumeArg;
        String templateType = 'professional';
        if (settings.arguments is Resume) {
          resumeArg = settings.arguments as Resume;
          templateType = resumeArg.templateType ?? 'professional';
        } else if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          resumeArg = args['resume'] as Resume?;
          templateType = args['templateType'] as String? ?? 'professional';
        }
        return MaterialPageRoute(
          builder: (_) =>
              ResumeEditorPage(resume: resumeArg, templateType: templateType),
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
        return MaterialPageRoute(
          builder: (_) => BlocProvider<AdminBloc>(
            create: (_) => di.sl<AdminBloc>(),
            child: const AdminDashboard(),
          ),
        );

      case AppRoutes.manageUsers:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<AdminBloc>(
            create: (_) => di.sl<AdminBloc>(),
            child: const ManageUsersPage(),
          ),
        );

      case AppRoutes.manageTemplates:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<AdminBloc>(
            create: (_) => di.sl<AdminBloc>(),
            child: const ManageTemplatesPage(),
          ),
        );

      case AppRoutes.atsSettings:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<AdminBloc>(
            create: (_) => di.sl<AdminBloc>(),
            child: const ATSSettingsPage(),
          ),
        );

      case AppRoutes.analytics:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<AdminBloc>(
            create: (_) => di.sl<AdminBloc>(),
            child: const AnalyticsPage(),
          ),
        );

      case AppRoutes.announcements:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<AdminBloc>(
            create: (_) => di.sl<AdminBloc>(),
            child: const AnnouncementsPage(),
          ),
        );

      case AppRoutes.sendNotification:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<AdminBloc>(
            create: (_) => di.sl<AdminBloc>(),
            child: const SendNotificationPage(),
          ),
        );

      case AppRoutes.templatePreview:
        final tmpl = settings.arguments as ResumeTemplate?;
        if (tmpl == null) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('No template data provided')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => BlocProvider<AdminBloc>(
            create: (_) => di.sl<AdminBloc>(),
            child: TemplatePreviewPage(template: tmpl),
          ),
        );

      case AppRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());

      case AppRoutes.resetPassword:
        final initialLinkOrCode = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) =>
              ResetPasswordPage(initialLinkOrCode: initialLinkOrCode),
        );

      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());

      case AppRoutes.privacy:
        return MaterialPageRoute(builder: (_) => const PrivacyPage());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Route ${settings.name} not found')),
          ),
        );
    }
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
            onTap: () => Navigator.pushNamed(context, AppRoutes.privacy),
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

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Security')),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          SwitchListTile(
            secondary: const Icon(Icons.analytics_outlined),
            title: const Text('Usage Analytics'),
            subtitle: const Text(
              'Help improve the app by sharing anonymous usage data',
            ),
            value: false,
            onChanged: (value) {},
          ),
          const Divider(),
          SwitchListTile(
            secondary: const Icon(Icons.backup_outlined),
            title: const Text('Cloud Backup'),
            subtitle: const Text(
              'Automatically backup your resumes to the cloud',
            ),
            value: true,
            onChanged: (value) {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Delete Account'),
            subtitle: const Text(
              'Permanently delete your account and all data',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Account?'),
                  content: const Text(
                    'This action is permanent and cannot be undone. All your resumes and data will be deleted.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CreateResumePage extends StatelessWidget {
  const CreateResumePage({super.key});

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
