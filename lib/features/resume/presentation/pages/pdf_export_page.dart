import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:resumebuilder/core/constants/app_colors.dart';
import 'package:resumebuilder/core/utils/pdf_helper.dart';
import 'package:resumebuilder/features/resume/domain/entities/resume.dart';

class PDFExportPage extends StatefulWidget {
  final Resume resume;

  const PDFExportPage({super.key, required this.resume});

  @override
  State<PDFExportPage> createState() => PDFExportPageState();
}

class PDFExportPageState extends State<PDFExportPage> {
  bool isGenerating = false;
  double progress = 0.0;
  String selectedTemplate = 'professional';
  Uint8List? pdfBytes;

  final List<Map<String, dynamic>> templates = [
    {
      'id': 'professional',
      'name': 'Professional',
      'description': 'Clean and corporate design',
      'icon': Icons.business_center,
    },
    {
      'id': 'modern',
      'name': 'Modern',
      'description': 'Contemporary with color accents',
      'icon': Icons.auto_awesome,
    },
    {
      'id': 'minimal',
      'name': 'Minimal',
      'description': 'Simple and elegant',
      'icon': Icons.minimize,
    },
    {
      'id': 'creative',
      'name': 'Creative',
      'description': 'Bold and unique layout',
      'icon': Icons.color_lens,
    },
  ];

  Future<void> generatePDF() async {
    setState(() {
      isGenerating = true;
      progress = 0.0;
    });

    // Simulate PDF generation progress
    for (int i = 0; i <= 100; i += 10) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        setState(() {
          progress = i / 100;
        });
      }
    }

    final generatedBytes = await PDFHelper.generateResumePDF(
      widget.resume,
      template: selectedTemplate,
    );

    if (mounted) {
      setState(() {
        isGenerating = false;
        progress = 1.0;
        pdfBytes = generatedBytes;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                'PDF generated (${(generatedBytes.length / 1024).toStringAsFixed(1)} KB)',
              ),
            ],
          ),
          backgroundColor: AppColors.accent,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> downloadPDF() async {
    final bytes = pdfBytes;
    if (bytes == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Generate the PDF first')));
      return;
    }
    final fileName =
        '${widget.resume.title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.pdf';
    try {
      final path = await PDFHelper.savePDF(bytes, fileName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF saved to: $path'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Fallback to share sheet if direct save fails
      await PDFHelper.sharePDF(bytes, fileName);
    }
  }

  Future<void> printPDF() async {
    final bytes = pdfBytes;
    if (bytes == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Generate the PDF first')));
      return;
    }
    await PDFHelper.printPDF(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export PDF')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Resume Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.description,
                            color: AppColors.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.resume.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.resume.personalInfo?.firstName ?? ""} ${widget.resume.personalInfo?.lastName ?? ""}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.resume.atsScore != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: getScoreColor(widget.resume.atsScore!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'ATS: ${widget.resume.atsScore}%',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Template Selection
            const Text(
              'Choose Template',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final template = templates[index];
                final isSelected = selectedTemplate == template['id'];

                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedTemplate = template['id'] as String;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : AppColors.cardLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.grey200,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          template['icon'] as IconData,
                          size: 32,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondaryLight,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          template['name'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          template['description'] as String,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondaryLight,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Export Options
            const Text(
              'Export Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Include ATS Score'),
                    subtitle: const Text('Show ATS score on resume'),
                    value: true,
                    onChanged: (value) {},
                    secondary: const Icon(Icons.assessment),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Include Photo'),
                    subtitle: const Text('Add profile photo to resume'),
                    value: false,
                    onChanged: (value) {},
                    secondary: const Icon(Icons.photo),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Color Mode'),
                    subtitle: const Text('Use colors in the resume'),
                    value: true,
                    onChanged: (value) {},
                    secondary: const Icon(Icons.palette),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Progress Indicator
            if (isGenerating) ...[
              Card(
                color: AppColors.accent.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.accent,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Generating PDF...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${(progress * 100).toInt()}% complete',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Action Buttons
            ElevatedButton.icon(
              onPressed: isGenerating ? null : generatePDF,
              icon: const Icon(Icons.picture_as_pdf),
              label: Text(isGenerating ? 'Generating...' : 'Generate PDF'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isGenerating ? null : downloadPDF,
                    icon: const Icon(Icons.download),
                    label: const Text('Download'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isGenerating ? null : printPDF,
                    icon: const Icon(Icons.print),
                    label: const Text('Print'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Color getScoreColor(int score) {
    if (score >= 80) return AppColors.scoreExcellent;
    if (score >= 60) return AppColors.scoreGood;
    if (score >= 40) return AppColors.scoreAverage;
    return AppColors.scorePoor;
  }
}
