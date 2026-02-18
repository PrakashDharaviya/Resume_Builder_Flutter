import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/resume.dart';

class ResumePreviewPage extends StatelessWidget {
  final Resume resume;

  const ResumePreviewPage({super.key, required this.resume});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Resume Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // Navigate to PDF export screen
              Navigator.pushNamed(
                context,
                AppRoutes.exportPDF,
                arguments: resume,
              );
            },
            tooltip: 'Download PDF',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share functionality - UI only')),
              );
            },
            tooltip: 'Share',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const Divider(height: 32),

                if (resume.personalInfo?.summary != null) ...[
                  _buildSummary(),
                  const SizedBox(height: 24),
                ],

                if (resume.experience.isNotEmpty) ...[
                  _buildSection(
                    title: AppStrings.experience,
                    icon: Icons.work,
                    child: Column(
                      children: resume.experience
                          .map((exp) => _buildExperienceItem(exp))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                if (resume.education.isNotEmpty) ...[
                  _buildSection(
                    title: AppStrings.education,
                    icon: Icons.school,
                    child: Column(
                      children: resume.education
                          .map((edu) => _buildEducationItem(edu))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                if (resume.skills.isNotEmpty) ...[
                  _buildSection(
                    title: AppStrings.skills,
                    icon: Icons.star,
                    child: _buildSkills(),
                  ),
                  const SizedBox(height: 24),
                ],

                if (resume.projects.isNotEmpty) ...[
                  _buildSection(
                    title: AppStrings.projects,
                    icon: Icons.folder,
                    child: Column(
                      children: resume.projects
                          .map((proj) => _buildProjectItem(proj))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                if (resume.certifications.isNotEmpty) ...[
                  _buildSection(
                    title: AppStrings.certifications,
                    icon: Icons.verified,
                    child: Column(
                      children: resume.certifications
                          .map((cert) => _buildCertificationItem(cert))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                if (resume.achievements.isNotEmpty) ...[
                  _buildSection(
                    title: AppStrings.achievements,
                    icon: Icons.emoji_events,
                    child: Column(
                      children: resume.achievements
                          .map((ach) => _buildAchievementItem(ach))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                if (resume.languages.isNotEmpty) ...[
                  _buildSection(
                    title: AppStrings.languages,
                    icon: Icons.language,
                    child: _buildLanguages(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.exportPDF, arguments: resume);
        },
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text('Export PDF'),
      ),
    );
  }

  Widget _buildHeader() {
    final personal = resume.personalInfo;

    if (personal == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${personal.firstName} ${personal.lastName}',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _buildContactItem(Icons.email, personal.email),
            if (personal.phone != null)
              _buildContactItem(Icons.phone, personal.phone!),
            if (personal.location != null)
              _buildContactItem(Icons.location_on, personal.location!),
            if (personal.website != null)
              _buildContactItem(Icons.link, personal.website!),
          ],
        ),
        if (resume.socialLinks != null) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              if (resume.socialLinks!.linkedin != null)
                _buildSocialLink(Icons.work, resume.socialLinks!.linkedin!),
              if (resume.socialLinks!.github != null)
                _buildSocialLink(Icons.code, resume.socialLinks!.github!),
              if (resume.socialLinks!.portfolio != null)
                _buildSocialLink(Icons.web, resume.socialLinks!.portfolio!),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondaryLight),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLink(IconData icon, String url) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            url.split('//').last.split('/')[0],
            style: const TextStyle(fontSize: 12, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: Text(
        resume.personalInfo?.summary ?? '',
        style: const TextStyle(
          fontSize: 14,
          height: 1.6,
          color: AppColors.textPrimaryLight,
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildExperienceItem(Experience experience) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            experience.jobTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${experience.company} ${experience.location != null ? '• ${experience.location}' : ''}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${DateFormatter.formatMonthYear(experience.startDate)} - ${experience.currentlyWorking ? 'Present' : DateFormatter.formatMonthYear(experience.endDate!)}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryLight,
            ),
          ),
          if (experience.description != null) ...[
            const SizedBox(height: 8),
            Text(
              experience.description!,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ],
          if (experience.responsibilities.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...experience.responsibilities.map(
              (resp) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Text(
                        resp,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEducationItem(Education education) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            education.degree,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            education.institution,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.accent,
            ),
          ),
          if (education.fieldOfStudy != null) ...[
            const SizedBox(height: 4),
            Text(
              education.fieldOfStudy!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            '${DateFormatter.formatMonthYear(education.startDate)} - ${education.currentlyStudying ? 'Present' : DateFormatter.formatMonthYear(education.endDate!)}${education.grade != null ? ' • ${education.grade}' : ''}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkills() {
    // Group skills by category
    final skillsByCategory = <String, List<Skill>>{};
    for (final skill in resume.skills) {
      final category = skill.category ?? 'Other';
      if (!skillsByCategory.containsKey(category)) {
        skillsByCategory[category] = [];
      }
      skillsByCategory[category]!.add(skill);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: skillsByCategory.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: entry.value.map((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '${skill.name} ${skill.proficiency != null ? '• ${skill.proficiency}' : ''}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProjectItem(Project project) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            project.description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textPrimaryLight,
            ),
          ),
          if (project.technologies.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: project.technologies.map((tech) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tech,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.accent,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          if (project.projectLink != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.link, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  project.projectLink!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCertificationItem(Certification certification) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            certification.name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${certification.issuingOrganization} • ${DateFormatter.formatMonthYear(certification.issueDate)}${certification.credentialId != null ? ' • ID: ${certification.credentialId}' : ''}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(Achievement achievement) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            achievement.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            achievement.description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textPrimaryLight,
            ),
          ),
          if (achievement.date != null) ...[
            const SizedBox(height: 4),
            Text(
              DateFormatter.formatMonthYear(achievement.date!),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLanguages() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: resume.languages.map((lang) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.cardLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.grey200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lang.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                lang.proficiency,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
