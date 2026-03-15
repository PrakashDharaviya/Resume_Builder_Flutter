import 'package:flutter/material.dart';
import 'package:resumebuilder/features/resume/domain/entities/resume.dart';
import 'package:resumebuilder/features/resume/presentation/widgets/template_renderers.dart';

/// Returns the correct template renderer widget based on templateType string.
Widget buildTemplateRenderer(String templateType, Resume resume) {
  switch (templateType) {
    case 'modern':
      return ModernTemplateRenderer(resume: resume);
    case 'minimal':
      return MinimalTemplateRenderer(resume: resume);
    case 'creative':
      return CreativeTemplateRenderer(resume: resume);
    case 'classic':
      return ClassicTemplateRenderer(resume: resume);
    case 'professional':
    default:
      return ProfessionalTemplateRenderer(resume: resume);
  }
}
