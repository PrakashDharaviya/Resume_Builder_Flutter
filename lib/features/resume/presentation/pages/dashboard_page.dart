import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/resume_bloc.dart';
import '../bloc/resume_event.dart';
import '../bloc/resume_state.dart';
import '../../domain/entities/resume.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<ResumeBloc>().add(const LoadAllResumesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.profile);
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final userName = authState is AuthAuthenticated
              ? authState.user.displayName
              : 'User';

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ResumeBloc>().add(const LoadAllResumesEvent());
            },
            child: LayoutBuilder(
              builder: (ctx, constraints) {
                final isTablet = constraints.maxWidth >= 600;
                final hPad = isTablet ? 24.0 : 16.0;
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeSection(userName, constraints.maxWidth),
                      const SizedBox(height: 24),
                      _buildResumesSection(isTablet),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoutes.createResume);
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Resume'),
      ),
    );
  }

  Widget _buildWelcomeSection(String userName, double width) {
    final titleSize = width < 360 ? 18.0 : 22.0;
    final subSize = width < 360 ? 13.0 : 15.0;
    final vPad = width < 360 ? 16.0 : 24.0;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: vPad),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${AppStrings.welcome}, $userName! 👋',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Let\'s build your perfect resume',
            style: TextStyle(fontSize: subSize, color: AppColors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildResumesSection([bool isTablet = false]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.myResumes,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            TextButton.icon(
              onPressed: () {
                context.read<ResumeBloc>().add(const LoadAllResumesEvent());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Resumes List
        BlocBuilder<ResumeBloc, ResumeState>(
          builder: (context, state) {
            if (state is ResumeLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (state is ResumeError) {
              return Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ResumeBloc>().add(
                          const LoadAllResumesEvent(),
                        );
                      },
                      child: const Text(AppStrings.retry),
                    ),
                  ],
                ),
              );
            }

            if (state is ResumeListLoaded) {
              if (state.resumes.isEmpty) {
                return _buildEmptyState();
              }
              if (isTablet) {
                // 2-column grid on tablets/landscape
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 0,
                    childAspectRatio: 1.55,
                  ),
                  itemCount: state.resumes.length,
                  itemBuilder: (context, index) =>
                      _buildResumeCard(state.resumes[index]),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.resumes.length,
                itemBuilder: (context, index) {
                  return _buildResumeCard(state.resumes[index]);
                },
              );
            }

            return _buildEmptyState();
          },
        ),
      ],
    );
  }

  Widget _buildResumeCard(Resume resume) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.of(
            context,
          ).pushNamed(AppRoutes.resumeEditor, arguments: resume);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Resume Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Resume Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resume.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${AppStrings.lastUpdated}: ${DateFormatter.getRelativeTime(resume.updatedAt)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),

                  // ATS Score Badge
                  if (resume.atsScore != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getScoreColor(resume.atsScore!),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${resume.atsScore}',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Action Buttons — responsive
              LayoutBuilder(
                builder: (ctx, constraints) {
                  final w = constraints.maxWidth;
                  // Compact style for narrow screens (< 320px)
                  if (w < 320) {
                    return Row(
                      children: [
                        _compactBtn(
                          icon: Icons.edit_outlined,
                          label: 'Edit',
                          filled: false,
                          onTap: () => Navigator.of(context).pushNamed(
                            AppRoutes.resumeEditor,
                            arguments: resume,
                          ),
                        ),
                        const SizedBox(width: 6),
                        _compactBtn(
                          icon: Icons.visibility_outlined,
                          label: 'Preview',
                          filled: false,
                          onTap: () => Navigator.of(context).pushNamed(
                            AppRoutes.resumePreview,
                            arguments: resume,
                          ),
                        ),
                        const SizedBox(width: 6),
                        _compactBtn(
                          icon: Icons.analytics_outlined,
                          label: 'Analyze',
                          filled: true,
                          onTap: () => Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.atsAnalysis, arguments: resume),
                        ),
                      ],
                    );
                  }
                  // Normal responsive row (≥ 320px)
                  final buttonPadding = w < 380
                      ? const EdgeInsets.symmetric(horizontal: 4, vertical: 10)
                      : const EdgeInsets.symmetric(horizontal: 8, vertical: 11);
                  final fontSize = w < 380 ? 12.0 : 13.0;
                  final iconSize = w < 380 ? 15.0 : 17.0;
                  return Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).pushNamed(
                            AppRoutes.resumeEditor,
                            arguments: resume,
                          ),
                          icon: Icon(Icons.edit_outlined, size: iconSize),
                          label: Text(
                            'Edit',
                            style: TextStyle(fontSize: fontSize),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: buttonPadding,
                            minimumSize: const Size(0, 38),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).pushNamed(
                            AppRoutes.resumePreview,
                            arguments: resume,
                          ),
                          icon: Icon(Icons.visibility_outlined, size: iconSize),
                          label: Text(
                            'Preview',
                            style: TextStyle(fontSize: fontSize),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: buttonPadding,
                            minimumSize: const Size(0, 38),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.atsAnalysis, arguments: resume),
                          icon: Icon(Icons.analytics_outlined, size: iconSize),
                          label: Text(
                            'Analyze',
                            style: TextStyle(fontSize: fontSize),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: buttonPadding,
                            minimumSize: const Size(0, 38),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 48),
          Icon(Icons.description_outlined, size: 96, color: AppColors.grey300),
          const SizedBox(height: 16),
          Text(
            AppStrings.noResumes,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.startCreating,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.createResume);
            },
            icon: const Icon(Icons.add),
            label: const Text(AppStrings.createNewResume),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppColors.scoreExcellent;
    if (score >= 60) return AppColors.scoreGood;
    if (score >= 40) return AppColors.scoreAverage;
    return AppColors.scorePoor;
  }

  // Compact icon+label button for very small screens
  Widget _compactBtn({
    required IconData icon,
    required String label,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: filled
          ? ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
                minimumSize: const Size(0, 36),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
                minimumSize: const Size(0, 36),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
