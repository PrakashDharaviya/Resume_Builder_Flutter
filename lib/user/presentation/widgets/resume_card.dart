import 'package:flutter/material.dart';
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
        subtitle: Text(
          'Updated ${resume.updatedAt.toLocal().toString().split(' ').first}',
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
