import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:resumebuilder/features/admin/domain/entities/resume_template.dart';
import 'package:resumebuilder/features/resume/presentation/widgets/template_renderer_factory.dart';
import 'package:resumebuilder/features/resume/presentation/widgets/template_renderers.dart';

class TemplateCard extends StatelessWidget {
  final ResumeTemplate template;
  final bool locked;
  final VoidCallback? onTap;

  const TemplateCard({
    super.key,
    required this.template,
    required this.locked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = _typeColor(template.templateType);

    return GestureDetector(
      onTap: locked ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          border: Border.all(
            color: locked
                ? Colors.grey.withValues(alpha: 0.3)
                : accentColor.withValues(alpha: 0.4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (locked ? Colors.grey : accentColor).withValues(
                alpha: 0.08,
              ),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Mini template preview ──
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (template.assetDataBase64.isNotEmpty)
                      _buildAssetPreview(template)
                    else
                      // Scale down the full template renderer
                      IgnorePointer(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          child: Container(
                            width: 600,
                            color: Colors.white,
                            child: buildTemplateRenderer(
                              template.templateType,
                              sampleResume,
                            ),
                          ),
                        ),
                      ),

                    // Gradient overlay at bottom for readability
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              (isDark ? Colors.black : Colors.white).withValues(
                                alpha: 0.7,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Locked overlay
                    if (locked)
                      Container(
                        color: Colors.black.withValues(alpha: 0.45),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.lock_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                              SizedBox(height: 6),
                              Text(
                                'PREMIUM',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ── Bottom info bar ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF111827)
                    : const Color(0xFFF9FAFB),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _typeIcon(template.templateType),
                    size: 16,
                    color: locked ? Colors.grey : accentColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      template.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (template.isPremium)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: locked
                            ? const Color(0xFFEF4444).withValues(alpha: 0.12)
                            : const Color(0xFFF59E0B).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            locked ? Icons.lock_rounded : Icons.star_rounded,
                            size: 11,
                            color: locked
                                ? const Color(0xFFEF4444)
                                : const Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            locked ? 'LOCKED' : 'PRO',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: locked
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFFF59E0B),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
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

  IconData _typeIcon(String type) {
    switch (type) {
      case 'professional':
        return Icons.business_center_rounded;
      case 'modern':
        return Icons.auto_awesome_rounded;
      case 'minimal':
        return Icons.minimize_rounded;
      case 'creative':
        return Icons.color_lens_rounded;
      case 'classic':
        return Icons.article_rounded;
      default:
        return Icons.article_outlined;
    }
  }

  Widget _buildAssetPreview(ResumeTemplate template) {
    try {
      final imageBytes = base64Decode(template.assetDataBase64);
      if (template.assetType == 'image') {
        return Image.memory(
          imageBytes,
          fit: BoxFit.cover,
          errorBuilder: (_, error, stackTrace) => _rendererFallback(),
        );
      } else if (template.assetType == 'pdf') {
        // PDF badge indicator
        return Container(
          color: const Color(0xFFF8FAFC),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.picture_as_pdf_rounded,
                  size: 46,
                  color: Color(0xFFEF4444),
                ),
                SizedBox(height: 8),
                Text(
                  'PDF Template',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      // Fallback if base64 decode fails
      return _rendererFallback();
    }
    return _rendererFallback();
  }

  Widget _rendererFallback() {
    return IgnorePointer(
      child: FittedBox(
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        child: Container(
          width: 600,
          color: Colors.white,
          child: buildTemplateRenderer(template.templateType, sampleResume),
        ),
      ),
    );
  }
}
