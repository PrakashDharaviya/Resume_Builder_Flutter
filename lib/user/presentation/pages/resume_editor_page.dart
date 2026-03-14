import 'package:flutter/material.dart';
import '../../../features/resume/domain/entities/resume.dart';
import '../../../features/resume/presentation/pages/resume_editor_page.dart'
    as legacy;

class ResumeEditorPage extends StatelessWidget {
  final Resume? resume;
  final String templateType;

  const ResumeEditorPage({
    super.key,
    this.resume,
    this.templateType = 'professional',
  });

  @override
  Widget build(BuildContext context) {
    return legacy.ResumeEditorPage(
      resume: resume,
      templateType: templateType,
    );
  }
}
