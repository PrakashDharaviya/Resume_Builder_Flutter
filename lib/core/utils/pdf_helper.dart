import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:resumebuilder/features/resume/domain/entities/resume.dart';

class PDFHelper {
  static final dateFormat = DateFormat('MMM yyyy');

  /// Generates a real PDF document from a [Resume] entity.
  static Future<Uint8List> generateResumePDF(
    Resume resume, {
    String template = 'professional',
  }) async {
    final pdf = pw.Document();
    final personal = resume.personalInfo;

    // Load Google Fonts that support full Unicode (bullets, em-dashes, etc.)
    final regularFont = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();
    final italicFont = await PdfGoogleFonts.robotoItalic();

    final baseTheme = pw.ThemeData.withFont(
      base: regularFont,
      bold: boldFont,
      italic: italicFont,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: baseTheme,
        build: (context) => [
          // Header – name & contact
          if (personal != null) ...[
            pw.Text(
              personal.fullName,
              style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Row(
              children: [
                if (personal.email.isNotEmpty) contactChip(personal.email),
                if (personal.phone != null && personal.phone!.isNotEmpty)
                  contactChip(personal.phone!),
                if (personal.location != null && personal.location!.isNotEmpty)
                  contactChip(personal.location!),
                if (personal.website != null && personal.website!.isNotEmpty)
                  contactChip(personal.website!),
              ],
            ),
            if (personal.summary != null && personal.summary!.isNotEmpty) ...[
              pw.SizedBox(height: 12),
              pw.Text(
                personal.summary!,
                style: const pw.TextStyle(fontSize: 11, lineSpacing: 2),
              ),
            ],
            pw.Divider(),
          ],

          // Experience
          if (resume.experience.isNotEmpty) ...[
            sectionTitle('Experience'),
            for (final exp in resume.experience) ...[
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      '${exp.jobTitle} — ${exp.company}',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Text(
                    dateRange(
                      exp.startDate,
                      exp.endDate,
                      exp.currentlyWorking,
                    ),
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
              if (exp.location != null && exp.location!.isNotEmpty)
                pw.Text(
                  exp.location!,
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                ),
              if (exp.description != null && exp.description!.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 4),
                  child: pw.Text(
                    exp.description!,
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
              for (final r in exp.responsibilities)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 12, top: 2),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        width: 4,
                        height: 4,
                        margin: const pw.EdgeInsets.only(top: 4, right: 8),
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.black,
                          shape: pw.BoxShape.circle,
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          r,
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              pw.SizedBox(height: 8),
            ],
          ],

          // Education
          if (resume.education.isNotEmpty) ...[
            sectionTitle('Education'),
            for (final edu in resume.education) ...[
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      '${edu.degree}${edu.fieldOfStudy != null ? " in ${edu.fieldOfStudy}" : ""}',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Text(
                    dateRange(
                      edu.startDate,
                      edu.endDate,
                      edu.currentlyStudying,
                    ),
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
              pw.Text(edu.institution, style: const pw.TextStyle(fontSize: 11)),
              if (edu.grade != null && edu.grade!.isNotEmpty)
                pw.Text(
                  'Grade: ${edu.grade}',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                ),
              pw.SizedBox(height: 8),
            ],
          ],

          // Skills
          if (resume.skills.isNotEmpty) ...[
            sectionTitle('Skills'),
            pw.Wrap(
              spacing: 6,
              runSpacing: 6,
              children: resume.skills
                  .map(
                    (s) => pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey400),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        s.proficiency != null
                            ? '${s.name} (${s.proficiency})'
                            : s.name,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                  )
                  .toList(),
            ),
            pw.SizedBox(height: 12),
          ],

          // Projects
          if (resume.projects.isNotEmpty) ...[
            sectionTitle('Projects'),
            for (final proj in resume.projects) ...[
              pw.Text(
                proj.name,
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                proj.description,
                style: const pw.TextStyle(fontSize: 10),
              ),
              if (proj.technologies.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 2),
                  child: pw.Text(
                    'Technologies: ${proj.technologies.join(", ")}',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                ),
              pw.SizedBox(height: 8),
            ],
          ],

          // Certifications
          if (resume.certifications.isNotEmpty) ...[
            sectionTitle('Certifications'),
            for (final cert in resume.certifications) ...[
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      cert.name,
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Text(
                    dateFormat.format(cert.issueDate),
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
              pw.Text(
                cert.issuingOrganization,
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 6),
            ],
          ],

          // Languages
          if (resume.languages.isNotEmpty) ...[
            sectionTitle('Languages'),
            pw.Wrap(
              spacing: 16,
              runSpacing: 4,
              children: resume.languages
                  .map(
                    (l) => pw.Text(
                      '${l.name} — ${l.proficiency}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  )
                  .toList(),
            ),
            pw.SizedBox(height: 12),
          ],

          // Achievements
          if (resume.achievements.isNotEmpty) ...[
            sectionTitle('Achievements'),
            for (final a in resume.achievements) ...[
              pw.Text(
                a.title,
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(a.description, style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 6),
            ],
          ],
        ],
      ),
    );

    return pdf.save();
  }

  /// Saves the PDF file to the device's Downloads / Documents directory
  /// and returns the full file path.
  static Future<String> savePDF(Uint8List pdfBytes, String fileName) async {
    Directory? dir;
    if (Platform.isAndroid) {
      dir = Directory('/storage/emulated/0/Download');
      if (!await dir.exists()) {
        dir = await getExternalStorageDirectory();
      }
    } else {
      dir = await getApplicationDocumentsDirectory();
    }
    dir ??= await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(pdfBytes);
    return file.path;
  }

  /// Opens the system print / save-as-PDF dialog.
  static Future<void> printPDF(Uint8List pdfBytes) async {
    await Printing.layoutPdf(onLayout: (_) => pdfBytes);
  }

  /// Opens the platform share sheet with the PDF attached.
  static Future<void> sharePDF(Uint8List pdfBytes, String fileName) async {
    await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
  }

  // ── helpers ──────────────────────────────────────────────

  static pw.Widget sectionTitle(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title.toUpperCase(),
          style: pw.TextStyle(
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blueGrey800,
          ),
        ),
        pw.Divider(thickness: 0.5),
        pw.SizedBox(height: 4),
      ],
    );
  }

  static pw.Widget contactChip(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(right: 12),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
    );
  }

  static String dateRange(DateTime start, DateTime? end, bool isCurrent) {
    final s = dateFormat.format(start);
    if (isCurrent) return '$s — Present';
    if (end != null) return '$s — ${dateFormat.format(end)}';
    return s;
  }
}
