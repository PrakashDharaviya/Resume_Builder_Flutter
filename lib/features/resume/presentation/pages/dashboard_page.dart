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
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  _buildWelcomeSection(userName),
                  const SizedBox(height: 32),

                  // Resumes Section
                  _buildResumesSection(),
                ],
              ),
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

  Widget _buildWelcomeSection(String userName) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${AppStrings.welcome}, $userName!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Let\'s build your perfect resume',
            style: TextStyle(fontSize: 16, color: AppColors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildResumesSection() {
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
                      color: AppColors.primary.withOpacity(0.1),
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

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.resumeEditor, arguments: resume);
                      },
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text(AppStrings.edit),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.resumePreview, arguments: resume);
                      },
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('Preview'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.atsAnalysis, arguments: resume);
                      },
                      icon: const Icon(Icons.analytics_outlined, size: 18),
                      label: const Text('Analyze'),
                    ),
                  ),
                ],
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
}
