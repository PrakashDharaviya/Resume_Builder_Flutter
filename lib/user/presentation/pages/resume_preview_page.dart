import 'package:flutter/material.dart';
import '../../../features/resume/domain/entities/resume.dart';
import '../../../features/resume/presentation/pages/resume_preview_page.dart'
    as legacy;

class ResumePreviewPage extends StatelessWidget {
  final Resume resume;

  const ResumePreviewPage({super.key, required this.resume});

  @override
  Widget build(BuildContext context) {
    return legacy.ResumePreviewPage(resume: resume);
  }
}
