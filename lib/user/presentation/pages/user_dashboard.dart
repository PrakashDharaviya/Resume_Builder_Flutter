import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resumebuilder/core/constants/app_routes.dart';
import 'package:resumebuilder/core/services/mock_database_service.dart';
import 'package:resumebuilder/core/utils/app_preferences.dart';
import 'package:resumebuilder/features/admin/domain/entities/announcement.dart';
import 'package:resumebuilder/features/admin/domain/entities/resume_template.dart';
import 'package:resumebuilder/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:resumebuilder/features/auth/presentation/bloc/auth_state.dart';
import 'package:resumebuilder/features/resume/domain/entities/resume.dart';
import 'package:resumebuilder/features/resume/presentation/bloc/resume_bloc.dart';
import 'package:resumebuilder/features/resume/presentation/bloc/resume_event.dart';
import 'package:resumebuilder/features/resume/presentation/bloc/resume_state.dart';
import 'package:resumebuilder/user/presentation/widgets/resume_card.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => UserDashboardState();
}

class UserDashboardState extends State<UserDashboard> {
  Future<void> confirmDeleteResume(Resume resume) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Resume'),
        content: const Text(
          'Are you sure you want to permanently delete this resume?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      context.read<ResumeBloc>().add(DeleteResumeEvent(resume.id));
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<ResumeBloc>().add(const LoadAllResumesEvent());
    _loadNotificationReadTime();
  }

  Future<void> _loadNotificationReadTime() async {
    await AppPreferences.loadLastReadTime();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<List<Announcement>>(
      future: MockDatabaseService.instance.getActiveAnnouncements(),
      builder: (context, snapshot) {
        final announcements = snapshot.data ?? const <Announcement>[];
        final announcement = announcements.isNotEmpty
            ? announcements.first
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
                icon: const Icon(Icons.style_rounded),
                tooltip: 'Templates',
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.templateSelection,
                  ).then((_) {
                    if (!context.mounted) return;
                    context.read<ResumeBloc>().add(const LoadAllResumesEvent());
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.person_outline_rounded),
                tooltip: 'Profile',
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.profile),
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
                child: BlocListener<ResumeBloc, ResumeState>(
                  listener: (context, state) {
                    if (state is ResumeDeleted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Resume deleted successfully'),
                        ),
                      );
                      context.read<ResumeBloc>().add(
                        const LoadAllResumesEvent(),
                      );
                    }
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
                                    colors: [
                                      Color(0xFF10B981),
                                      Color(0xFF34D399),
                                    ],
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
                          const SizedBox(height: 12),
                          FutureBuilder<List<ResumeTemplate>>(
                            future: MockDatabaseService.instance.getTemplates(),
                            builder: (context, templateSnap) {
                              final activeTemplates =
                                  (templateSnap.data ??
                                          const <ResumeTemplate>[])
                                      .where((t) => t.isActive)
                                      .toList();
                              final premiumCount = activeTemplates
                                  .where((t) => t.isPremium)
                                  .length;

                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: isDark
                                      ? const Color(0xFF1F2937)
                                      : const Color(0xFFF9FAFB),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF10B981,
                                    ).withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF10B981,
                                        ).withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.style_rounded,
                                        color: Color(0xFF10B981),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${activeTemplates.length} active templates available',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: isDark
                                                  ? Colors.white
                                                  : const Color(0xFF111827),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '$premiumCount premium template${premiumCount == 1 ? '' : 's'}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark
                                                  ? const Color(0xFF9CA3AF)
                                                  : const Color(0xFF6B7280),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.templateSelection,
                                        ).then((_) {
                                          if (!context.mounted) return;
                                          context.read<ResumeBloc>().add(
                                            const LoadAllResumesEvent(),
                                          );
                                        });
                                      },
                                      child: const Text('Browse'),
                                    ),
                                  ],
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                          // Recently used templates (based on user's resumes)
                          BlocBuilder<ResumeBloc, ResumeState>(
                            builder: (context, state) {
                              if (state is! ResumeListLoaded ||
                                  state.resumes.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              final resumes = [...state.resumes]
                                ..sort(
                                  (a, b) => b.updatedAt.compareTo(a.updatedAt),
                                );

                              final seenTypes = <String>{};
                              final recentResumes = <Resume>[];

                              for (final resume in resumes) {
                                final type =
                                    (resume.templateType ?? 'professional')
                                        .toLowerCase();
                                if (seenTypes.add(type)) {
                                  recentResumes.add(resume);
                                  if (recentResumes.length == 3) break;
                                }
                              }

                              if (recentResumes.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Recently Used Templates',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: recentResumes.map((resume) {
                                        final type =
                                            (resume.templateType ??
                                                    'professional')
                                                .toLowerCase();
                                        final label =
                                            ResumeTemplate.templateTypeLabel(
                                              type,
                                            );
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            right: 8,
                                          ),
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            onTap: () {
                                              Navigator.pushNamed(
                                                context,
                                                AppRoutes.resumePreview,
                                                arguments: resume,
                                              ).then((_) {
                                                if (!context.mounted) return;
                                                context.read<ResumeBloc>().add(
                                                  const LoadAllResumesEvent(),
                                                );
                                              });
                                            },
                                            child: Container(
                                              width: 220,
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: isDark
                                                    ? const Color(0xFF111827)
                                                    : const Color(0xFFF9FAFB),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: const Color(
                                                    0xFF10B981,
                                                  ).withValues(alpha: 0.35),
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    label,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    resume.title,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    'Updated ${resume.updatedAt.toLocal().toString().split(' ').first}',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: isDark
                                                          ? const Color(
                                                              0xFF9CA3AF,
                                                            )
                                                          : const Color(
                                                              0xFF6B7280,
                                                            ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                ],
                              );
                            },
                          ),
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
                              if (state is ResumeError) {
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: isDark
                                        ? const Color(0xFF1F2937)
                                        : const Color(0xFFFEE2E2),
                                  ),
                                  child: Text(
                                    'Error loading resumes: ${state.message}',
                                    style: const TextStyle(
                                      color: Color(0xFFB91C1C),
                                    ),
                                  ),
                                );
                              }
                              if (state is ResumeListLoaded &&
                                  state.resumes.isNotEmpty) {
                                return Column(
                                  children: state.resumes
                                      .map(
                                        (resume) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          child: ResumeCard(
                                            resume: resume,
                                            onDelete: () =>
                                                confirmDeleteResume(resume),
                                            onEdit: () {
                                              Navigator.pushNamed(
                                                context,
                                                AppRoutes.resumeEditor,
                                                arguments: resume,
                                              ).then((_) {
                                                if (!context.mounted) return;
                                                context.read<ResumeBloc>().add(
                                                  const LoadAllResumesEvent(),
                                                );
                                              });
                                            },
                                            onTap: () {
                                              Navigator.pushNamed(
                                                context,
                                                AppRoutes.resumePreview,
                                                arguments: resume,
                                              ).then((_) {
                                                if (!context.mounted) return;
                                                context.read<ResumeBloc>().add(
                                                  const LoadAllResumesEvent(),
                                                );
                                              });
                                            },
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
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.resumeEditor).then((_) {
                if (!context.mounted) return;
                context.read<ResumeBloc>().add(const LoadAllResumesEvent());
              });
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create Resume'),
          ),
        );
      },
    );
  }
}
