import 'package:flutter/material.dart';
import '../../../core/constants/app_routes.dart';
import '../../../features/resume/domain/entities/resume.dart';

class ResumeCard extends StatelessWidget {
  final Resume resume;
  final VoidCallback? onTap;

  const ResumeCard({super.key, required this.resume, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          resume.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Updated ${resume.updatedAt.toLocal().toString().split(' ').first}',
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _typeColor(
                  resume.templateType ?? 'professional',
                ).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                (resume.templateType ?? 'Professional').toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _typeColor(resume.templateType ?? 'professional'),
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                Icons.download_rounded,
                color: Color(0xFF6366F1),
              ),
              tooltip: 'Download PDF',
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.exportPDF,
                  arguments: resume,
                );
              },
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'professional':
        return const Color(0xFF2B6CB0);
      case 'modern':
        return const Color(0xFF38BDF8);
      case 'minimal':
        return const Color(0xFF6B7280);
      case 'creative':
        return const Color(0xFF8B5CF6);
      case 'classic':
        return const Color(0xFF1F2937);
      default:
        return const Color(0xFF10B981);
    }
  }
}
