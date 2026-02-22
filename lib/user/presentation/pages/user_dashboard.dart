import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/services/mock_database_service.dart';
import '../../../core/utils/app_preferences.dart';
import '../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../features/resume/presentation/bloc/resume_bloc.dart';
import '../../../features/resume/presentation/bloc/resume_event.dart';
import '../../../features/resume/presentation/bloc/resume_state.dart';
import '../widgets/resume_card.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  @override
  void initState() {
    super.initState();
    context.read<ResumeBloc>().add(const LoadAllResumesEvent());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final announcement =
        MockDatabaseService.instance.getActiveAnnouncements().isNotEmpty
        ? MockDatabaseService.instance.getActiveAnnouncements().first
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ResumeIQ'),
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, themeMode, _) {
              final isDarkMode =
                  themeMode == ThemeMode.dark ||
                  (themeMode == ThemeMode.system &&
                      MediaQuery.platformBrightnessOf(context) ==
                          Brightness.dark);
              return IconButton(
                icon: Icon(
                  isDarkMode
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                ),
                tooltip: isDarkMode ? 'Light Mode' : 'Dark Mode',
                onPressed: () {
                  themeNotifier.value = isDarkMode
                      ? ThemeMode.light
                      : ThemeMode.dark;
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: 'Profile',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
          IconButton(
            icon: const Icon(Icons.style_rounded),
            tooltip: 'Templates',
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.templateSelection),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth >= 1024
              ? 900.0
              : (constraints.maxWidth >= 640 ? 680.0 : double.infinity);
          final sidePadding = constraints.maxWidth >= 640 ? 24.0 : 16.0;
          return RefreshIndicator(
            onRefresh: () async {
              context.read<ResumeBloc>().add(const LoadAllResumesEvent());
            },
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(sidePadding),
                  children: [
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (_, state) {
                        final name = state is AuthAuthenticated
                            ? state.user.displayName
                            : 'User';
                        return Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Text(
                            'Welcome, $name',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      },
                    ),
                    if (announcement != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: isDark
                              ? const Color(0xFF1F2937)
                              : const Color(0xFFECFDF5),
                          border: Border.all(
                            color: const Color(
                              0xFF10B981,
                            ).withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.campaign_rounded,
                              color: Color(0xFF10B981),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    announcement.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(announcement.message),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    const Text(
                      'My Resumes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    BlocBuilder<ResumeBloc, ResumeState>(
                      builder: (_, state) {
                        if (state is ResumeLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        if (state is ResumeListLoaded &&
                            state.resumes.isNotEmpty) {
                          return Column(
                            children: state.resumes
                                .map(
                                  (resume) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: ResumeCard(
                                      resume: resume,
                                      onTap: () => Navigator.pushNamed(
                                        context,
                                        AppRoutes.resumePreview,
                                        arguments: resume,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                        }
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: isDark
                                ? const Color(0xFF1F2937)
                                : const Color(0xFFF9FAFB),
                          ),
                          child: const Text(
                            'No resumes yet. Tap Create Resume to start.',
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.resumeEditor),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Create Resume'),
      ),
    );
  }
}
