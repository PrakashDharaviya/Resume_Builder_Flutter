import 'package:flutter/material.dart';
import '../../../features/admin/domain/entities/resume_template.dart';

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
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: locked ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).cardColor,
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            const Icon(Icons.description_outlined, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                template.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            if (template.isPremium)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: locked
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  locked ? 'LOCKED' : 'PRO',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
